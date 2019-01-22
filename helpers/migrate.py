#!/usr/bin/env python3

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import copy
import subprocess
import sys
import shutil
import re

MIGRATIONS = [
    {
        "resource_type": "random_id",
        "name": "random_project_id_suffix",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project",
        "name": "project",
        "rename": "main",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_service",
        "name": "project_services",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_compute_shared_vpc_service_project",
        "name": "shared_vpc_attachment",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "null_resource",
        "name": "delete_default_compute_service_account",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_service_account",
        "name": "default_service_account",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_iam_member",
        "name": "default_service_account_membership",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_iam_member",
        "name": "controlling_group_vpc_membership",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_compute_subnetwork_iam_member",
        "name": "service_account_role_to_vpc_subnets",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_compute_subnetwork_iam_member",
        "name": "apis_service_account_role_to_vpc_subnets",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_usage_export_bucket",
        "name": "usage_report_export",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_storage_bucket",
        "name": "project_bucket",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_storage_bucket_iam_member",
        "name": "s_account_storage_admin_on_project_bucket",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_storage_bucket_iam_member",
        "name": "api_s_account_storage_admin_on_project_bucket",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_compute_subnetwork_iam_member",
        "name": "gke_shared_vpc_subnets",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_iam_member",
        "name": "gke_host_agent",
        "module": ".module.project-factory"
    },
    {
        "resource_type": "google_project_iam_member",
        "name": "gsuite_group_role",
        "module": ".module.project-factory",
    },
    {
        "resource_type": "google_service_account_iam_member",
        "name": "service_account_grant_to_group",
        "module": ".module.project-factory",
    },
    {
        "resource_type": "google_compute_subnetwork_iam_member",
        "name": "group_role_to_vpc_subnets",
        "module": ".module.project-factory",
    },
    {
        "resource_type": "google_resource_manager_lien",
        "name": "lien",
        "module": ".module.project-factory",
    },
]


class GSuiteMigration:
    """
    Migrate the resources from a flat project factory to match the new
    module structure created by the G Suite refactor.
    """

    def __init__(self, project_factory):
        self.project_factory = project_factory

    def moves(self):
        """
        Generate the set of old/new resource pairs that will be migrated
        to the `core_project_factory` module.
        """
        resources = self.targets()
        moves = []
        for (old, migration) in resources:
            new = copy.deepcopy(old)
            new.module += migration["module"]

            # Update the copied resource with the "rename" value if it is set
            if "rename" in migration:
                new.name = migration["rename"]

            pair = (old.path(), new.path())
            moves.append(pair)

        return moves

    def targets(self):
        """
        A list of resources that will be moved to the `core_project_factory`
        module.
        """
        to_move = []

        for migration in MIGRATIONS:
            resource_type = migration["resource_type"]
            resource_name = migration["name"]
            matching_resources = self.project_factory.get_resources(
                resource_type,
                resource_name)
            to_move += [(r, migration) for r in matching_resources]

        return to_move


class TerraformModule:
    """
    A Terraform module with associated resources.
    """

    def __init__(self, name, resources):
        """
        Create a new module and associate it with a list of resources.
        """
        self.name = name
        self.resources = resources

    def get_resources(self, resource_type=None, resource_name=None):
        """
        Return a list of resources matching the given resource type and name.
        """

        ret = []
        for resource in self.resources:
            matches_type = (resource_type is None or
                            resource_type == resource.resource_type)

            name_pattern = re.compile(r'%s(\[\d+\])?' % resource_name)
            matches_name = (resource_name is None or
                            name_pattern.match(resource.name))

            if matches_type and matches_name:
                ret.append(resource)

        return ret

    def has_resource(self, resource_type=None, resource_name=None):
        """
        Does this module contain a resource with the matching type and name?
        """
        for resource in self.resources:
            matches_type = (resource_type is None or
                            resource_type == resource.resource_type)

            matches_name = (resource_name is None or
                            resource_name == resource.name)

            if matches_type and matches_name:
                return True

        return False

    def __repr__(self):
        return "{}({!r}, {!r})".format(
            self.__class__.__name__,
            self.name,
            [repr(resource) for resource in self.resources])


class TerraformResource:
    """
    A Terraform resource, defined by the the identifier of that resource.

    >>> path = 'module.project-factory.google_project.project'
    >>> resource = TerraformResource.from_path(path)
    >>> assert resource.module == 'module.project-factory'
    >>> assert resource.resource_type == 'google_project'
    >>> assert resource.name == 'project'
    """

    @classmethod
    def from_path(cls, path):
        """
        Generate a new Terraform resource, based on the fully qualified
        Terraform resource path.
        """
        if re.match(r'\A[\w.\[\]-]+\Z', path) is None:
            raise ValueError(
                "Invalid Terraform resource path {!r}".format(path))

        parts = path.split(".")
        name = parts.pop()
        resource_type = parts.pop()
        module = ".".join(parts)
        return cls(module, resource_type, name)

    def __init__(self, module, resource_type, name):
        """
        Create a new TerraformResource from a pre-parsed path.
        """
        self.module = module
        self.resource_type = resource_type
        self.name = name

    def path(self):
        """
        Return the fully qualified resource path.
        """
        parts = [self.module, self.resource_type, self.name]
        if parts[0] == '':
            del parts[0]
        return ".".join(parts)

    def __repr__(self):
        return "{}({!r}, {!r}, {!r})".format(
            self.__class__.__name__,
            self.module,
            self.resource_type,
            self.name)


def group_by_module(resources):
    """
    Group a set of resources according to their containing module.
    """

    groups = {}
    for resource in resources:
        if resource.module in groups:
            groups[resource.module].append(resource)
        else:
            groups[resource.module] = [resource]

    return [
        TerraformModule(name, contained)
        for name, contained in groups.items()
    ]


def read_state(statefile):
    """
    Read the terraform state at the given path.
    """
    argv = ["terraform", "state", "list", "-state", statefile]
    result = subprocess.run(argv,
                            capture_output=True,
                            check=True,
                            encoding='utf-8')
    elements = result.stdout.split("\n")
    elements.pop()
    return elements


def state_changes_for_module(module, statefile):
    """
    Compute the Terraform state changes (deletions and moves) for a single
    project-factory module.
    """
    commands = []

    migration = GSuiteMigration(module)

    for (old, new) in migration.moves():
        argv = ["terraform", "state", "mv", "-state", statefile, old, new]
        commands.append(argv)

    return commands


def migrate(statefile, dryrun=False):
    """
    Migrate the terraform state in `statefile` to match the post-refactor
    resource structure.
    """

    # Generate a list of Terraform resource states from the output of
    # `terraform state list`
    resources = [
        TerraformResource.from_path(path)
        for path in read_state(statefile)
    ]

    # Group resources based on the module where they're defined.
    modules = group_by_module(resources)

    # Filter our list of Terraform modules down to anything that lookst like a
    # project-factory module. We key this off the presence off of
    # `random_id.random_project_id_suffix` since that should almost always be
    # unique to a project-factory module.
    factories = [
        module for module in modules
        if module.has_resource("random_id", "random_project_id_suffix")
        and module.has_resource("google_project", "project")
    ]

    print("---- Migrating the following project-factory modules:")
    for factory in factories:
        print("-- " + factory.name)

    # Collect a list of resources for each project factory that need to be
    # migrated.
    commands = []
    for factory in factories:
        commands += state_changes_for_module(factory, statefile)

    for argv in commands:
        if dryrun:
            print(" ".join(argv))
        else:
            subprocess.run(argv, check=True, encoding='utf-8')


def main(argv):
    parser = argparser()
    args = parser.parse_args(argv[1:])

    print("cp {} {}".format(args.oldstate, args.newstate))
    shutil.copy(args.oldstate, args.newstate)

    migrate(args.newstate, dryrun=args.dryrun)
    print("State migration complete, verify migration with "
          "`terraform plan -state '{}'`".format(args.newstate))


def argparser():
    parser = argparse.ArgumentParser(description='Migrate Terraform state')
    parser.add_argument('oldstate', metavar='oldstate.json',
                        help='The current Terraform state (will not be '
                             'modified)')
    parser.add_argument('newstate', metavar='newstate.json',
                        help='The path to the new state file')
    parser.add_argument('--dryrun', action='store_true',
                        help='Print the `terraform state mv` commands instead '
                             'of running the commands.')
    return parser


if __name__ == "__main__":
    main(sys.argv)
