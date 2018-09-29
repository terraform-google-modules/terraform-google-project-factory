#!/usr/bin/env python3

"""usage: migrate.py <old-state> <new-state>"""

import argparse
import copy
import subprocess
import sys


class GSuiteMigration:
    """
    Migrate the resources from a flat project factory to match the new
    module structure created by the G Suite refactor.
    """

    GSUITE_ENABLED_SELECTORS = [
        ("gsuite_group", "group"),
        ("gsuite_group_member", "api_s_account_api_sa_group_member"),
        ("gsuite_group_member", "service_account_sa_group_member"),
        ("null_data_source", "data_given_group_email"),
        ("null_data_source", "data_final_group_email"),
    ]

    CORE_PROJECT_FACTORY_SELECTORS = [
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

    def commands(self):
        return self.mv_gsuite_resources() + \
            self.mv_core_project_factory_resources()

    def gsuite_enabled_resources(self):
        """
        A list of resources that will be moved to the `gsuite_enabled` module.
        """
        selectors = self.__class__.GSUITE_ENABLED_SELECTORS
        return self._select_resources(selectors)

    def mv_gsuite_resources(self):
        return self._mv_resources(
            self.gsuite_enabled_resources(),
            ".module.gsuite-enabled")

    def core_project_factory_resources(self):
        """
        A list of resources that will be moved to the `core_project_factory`
        module.
        """
        selectors = self.__class__.CORE_PROJECT_FACTORY_SELECTORS
        return self._select_resources(selectors)

    def mv_core_project_factory_resources(self):
        return self._mv_resources(
            self.core_project_factory_resources(),
            ".module.project-factory")

    def _mv_resources(self, resources, path):
        mv_commands = []
        for old in resources:
            new = copy.deepcopy(old)
            new.module += path

            cmd = "terraform state mv {} {}".format(old.path(), new.path())
            mv_commands.append(cmd)

        return mv_commands

    def _select_resources(self, selectors):
        to_move = []
        for selector in selectors:
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


def main(argv):
    parser = argparser()
    args = parser.parse_args(argv[1:])

    resources = [
        TerraformResource.from_path(path)
        for path in read_state(args.oldstate)
    ]

    modules = group(resources)
    factories = [
        module for module in modules
        if module.has_resource("random_id", "random_project_id_suffix")
    ]

    print("---- Candidate modules:")
    for factory in factories:
        print("-- " + factory.name)

    print("---- Plan:")
    to_move = []
    for factory in factories:
        migration = GSuiteMigration(factory)

        to_move += migration.commands()

    for cmd in to_move:
        print(cmd)


def argparser():
    parser = argparse.ArgumentParser(description='Migrate Terraform state')
    parser.add_argument('oldstate', metavar='oldstate.json',
                        help='The current Terraform state (will not be '
                             'modified)')
    parser.add_argument('newstate', metavar='newstate.json',
                        help='The path to the new state file')
    return parser


if __name__ == "__main__":
    main(sys.argv)
