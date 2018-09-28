#!/usr/bin/env python3

"""usage: migrate.py <old-state> <new-state>"""

import argparse
import pprint
import subprocess
import sys


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

    def has_resource(self, resource_type, resource_name):
        """
        Does this module contain a resource with the matching type and name?
        """
        for resource in self.resources:
            if resource.resource_type == resource_type \
                    and resource.name == resource_name:
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
    pprint.pprint(resources)
    modules = group(resources)
    pprint.pprint(modules)
    print("done")


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
