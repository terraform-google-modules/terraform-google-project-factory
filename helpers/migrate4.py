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

# flake8: noqa

import argparse
import copy
import subprocess
import sys
import shutil
import re

MIGRATIONS = [
    {
        "resource_type": "google_project_service",
        "name": "project_services",
        "module": ".module.project_services",
    },
]


class ProjectServicesMigration:
    """
    Migrate the project services resources from a project factory to match the
    new module structure created by the project services deprecation and
    breakout into its own module.
    """

    def __init__(self, project_factory, statefile):
        self.project_factory = project_factory
        self.statefile = statefile

    def moves(self):
        """
        Generate the set of old/new resource pairs that will be migrated
        to the `project_services` module.
        """
        resources = self.targets()
        moves = []
        for (old, migration) in resources:
            new = copy.deepcopy(old)
            new.module += migration["module"]

            # Update the copied resource with the "rename" value if it is set
            if "rename" in migration:
                new.name = migration["rename"]
            else:
                # Write over with base name to remove "[0]" suffix
                new.name = migration["name"]

            # Update the new name with the for_each suffix
            service_name = read_resource_value(old.path(), "service", self.statefile)
            if service_name is None:
                raise ValueError(
                    "Could not find project service ID for resource {!r}".format(old.path()))

            new.name = '{}["{}"]'.format(new.name, service_name)

            # Create an ID string for importing the resource
            project_id = read_resource_value(old.path(), "project", self.statefile)
            if project_id is None:
                raise ValueError(
                    "Could not find project ID for resource {!r}".format(old.path()))

            import_address = "{}/{}".format(project_id, service_name)

            pair = (old.path(), new.path(), import_address)
            moves.append(pair)

        return moves

    def targets(self):
        """
        A list of resources that will be moved to the `project_services`
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

        name_pattern = re.compile(r'%s(\[\d+\])?' % resource_name)

        ret = []
        for resource in self.resources:
            matches_type = (resource_type is None or
                            resource_type == resource.resource_type)

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
    argv = ["terraform", "state", "list", *statefile]
    result = subprocess.run(argv,
                            capture_output=True,
                            check=True,
                            encoding='utf-8')
    elements = result.stdout.split("\n")
    elements.pop()
    return elements


def read_resource_value(resource, field, statefile):
    """
    Read a specific value from a resource from the terraform state at the
    given path.
    """
    argv = ["terraform", "state", "show", "-no-color", *statefile, resource]
    result = subprocess.run(argv,
                            capture_output=True,
                            check=True,
                            encoding='utf-8')
    lines = result.stdout.split("\n")

    regex = re.compile(r'{}\s*=\s*"([\w.-]+)"'.format(field))
    for line in lines:
        search = regex.search(line)
        if search:
            return search.group(1)


def state_changes_for_module(module, statefile):
    """
    Compute the Terraform state changes (deletions and moves) for a single
    project-factory module.
    """
    commands = []

    migration = ProjectServicesMigration(module, statefile)

    for (old, new, id) in migration.moves():
        argv = ["terraform", "state", "rm", *statefile, old]
        commands.append(argv)
        argv = ["terraform", "import", *statefile, new, id]
        commands.append(argv)

    return commands


def migrate(statefile, dryrun=False, verbose=False):
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
        and module.has_resource("google_project_service", "project_services[0]")
    ]

    print("---- Migrating the following project-factory modules:")

    # Collect a list of resources for each project factory that need to be
    # migrated.
    commands = []
    for factory in factories:
        print("-- " + factory.name)
        commands += state_changes_for_module(factory, statefile)

    for argv in commands:
        if dryrun or verbose:
            print(" ".join(argv))
        if not dryrun:
            subprocess.run(argv, check=True, encoding='utf-8')


def main(argv):
    parser = argparser()
    args = parser.parse_args(argv[1:])

    state = []
    plan_command = "terraform plan"
    if args.state:
        state = ["-state", args.state]
        plan_command += " {}".format(' '.join(state))

    migrate(state, dryrun=args.dryrun, verbose=args.verbose)
    print("State migration complete, verify migration with "
          "`{}`".format(plan_command))


def argparser():
    parser = argparse.ArgumentParser(description='Migrate Terraform state')
    parser.add_argument('--state',
                        help='The Terraform state file to modify, otherwise '
                        'Terraform default')
    parser.add_argument('--dryrun', action='store_true',
                        help='Print the `terraform state mv` commands instead '
                             'of running the commands.')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Print the `terraform state mv` commands that '
                             'are run.')
    return parser


if __name__ == "__main__":
    main(sys.argv)
