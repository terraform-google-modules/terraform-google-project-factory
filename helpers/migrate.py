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


class GSuiteMigration:
    """
    Migrate the resources from a flat project factory to match the new
    module structure created by the G Suite refactor.
    """

    CORE_PROJECT_FACTORY_SELECTORS = [
        ("google_organization", "org"),
        ("google_compute_default_service_account", "default"),
        ("null_data_source", "data_final_group_email"),
        ("null_data_source", "data_group_email_format"),
        ("google_compute_shared_vpc_service_project", None),
        ("google_compute_subnetwork_iam_member", None),
        ("google_project", None),
        ("google_project_iam_member", None),
        ("google_project_service", None),
        ("google_project_usage_export_bucket", None),
        ("google_service_account", None),
        ("google_service_account_iam_member", None),
        ("google_storage_bucket", None),
        ("google_storage_bucket_iam_member", None),
        ("null_resource", None),
        ("random_id", None),
    ]

    def __init__(self, project_factory):
        self.project_factory = project_factory

    def moves(self):
        """
        Generate the set of old/new resource pairs that will be migrated
        to the `core_project_factory` module.
        """
        resources = self.targets()
        moves = []
        for old in resources:
            new = copy.deepcopy(old)
            new.module += ".module.project-factory"

            pair = (old.path(), new.path())
            moves.append(pair)

        return moves

    def targets(self):
        """
        A list of resources that will be moved to the `core_project_factory`
        module.
        """
        to_move = []

        for selector in self.__class__.CORE_PROJECT_FACTORY_SELECTORS:
            resource_type = selector[0]
            resource_name = selector[1]
            matching_resources = self.project_factory.get_resources(
                resource_type,
                resource_name)
            to_move += matching_resources

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

            matches_name = (resource_name is None or
                            resource_name == resource.name)

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
            raise ValueError("Invalid Terraform resource path {!r}".format(path))

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


def group(resources):
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
    modules = group(resources)

    # Filter our list of Terraform modules down to anything that lookst like a
    # project-factory module. We key this off the presence off of
    # `random_id.random_project_id_suffix` since that should almost always be
    # unique to a project-factory module.
    factories = [
        module for module in modules
        if module.has_resource("random_id", "random_project_id_suffix")
    ]

    print("---- Migrating the following project-factory modules:")
    for factory in factories:
        print("-- " + factory.name)

    # Collect a list of resources for each project factory that need to be
    # migrated.
    to_move = []
    for factory in factories:
        migration = GSuiteMigration(factory)
        to_move += migration.moves()

    for (old, new) in to_move:
        argv = ["terraform", "state", "mv", "-state", statefile, old, new]
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
    print("State migration complete, verify migration with `terraform plan`")


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
