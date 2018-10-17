#!/usr/bin/env python

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
import json
import logging
import sys
import os

try:
    from google.oauth2 import service_account
    from googleapiclient import discovery
except ImportError as e:
    if os.environ.get('GRACEFUL_IMPORTERROR', '') != '':
        sys.stderr.write("Unable to import Google API dependencies, skipping "
                         "GCP precondition checks!\n")
        sys.exit(0)
    else:
        raise e


class Requirements:
    def __init__(self, req_type, resource, required, provided):
        self.req_type = req_type
        self.resource = resource
        self.required = set(required)
        self.provided = set(provided)

    def is_satisfied(self):
        """
        Is this requirement satisfied?
        """
        return (self.required & self.provided) == self.required

    def satisfied(self):
        """
        Generate a list of requirements that have been satisfied. Resources
        that were provided but aren't required are not returned.
        """
        return list(self.required & self.provided)

    def unsatisfied(self):
        """
        Generate a list of requirements that have not been satisfied.
        """
        return list(self.required - self.provided)

    def asdict(self):
        return {
            "type": self.req_type,
            "name": self.resource,
            "satisfied": self.satisfied(),
            "unsatisfied": self.unsatisfied(),
        }


class OrgPermissions:
    # Permissions that the service account must have for any organization
    ALL_PERMISSIONS = [
        # Typically granted with `roles/resourcemanager.organizationViewer`
        "resourcemanager.organizations.get",

        # Typically granted with `roles/iam.serviceAccountAdmin`
        "iam.serviceAccounts.setIamPolicy",
    ]

    # Permissions required when the service account is attaching a new project
    # to a shared VPC
    SHARED_VPC_PERMISSIONS = [
        # Typically granted with `roles/compute.networkAdmin`
        "compute.subnetworks.setIamPolicy",

        # Typically granted with `roles/compute.xpnAdmin`
        "compute.organizations.enableXpnResource",
    ]

    # Permissions required when the service account is creating a new project
    # directly within an organization (as opposed to a folder)
    PARENT_PERMISSIONS = [
        # Typically granted with `roles/resourcemanager.projectCreator`
        "resourcemanager.projects.create"
    ]

    def __init__(self, org_id, shared_vpc=False, parent=False):
        """
        Create a new organization validator.

        Args:
            org_id (str): The organization ID
            shared_vpc (bool): Whether shared VPC permissions should be checked
            parent (bool): Whether parent permissions should be checked
        """
        self.org_id = org_id
        self.shared_vpc = shared_vpc
        self.parent = parent

        self.permissions = self.ALL_PERMISSIONS[:]

        if self.shared_vpc:
            self.permissions += self.SHARED_VPC_PERMISSIONS

        if self.parent:
            self.permissions += self.PARENT_PERMISSIONS

    def validate(self, credentials):
        service = discovery.build(
            'cloudresourcemanager', 'v1',
            credentials=credentials
        )

        body = {"permissions": self.permissions}
        resource = "organizations/" + self.org_id

        request = service.organizations().testIamPermissions(
            resource=resource,
            body=body)
        response = request.execute()

        req = Requirements(
            "Service account permissions on organization",
            resource,
            self.permissions,
            response["permissions"],
        )

        return req.asdict()


class FolderPermissions:
    # Permissions required when the service account is creating a project
    # within a folder (as opposed to an organization).
    PARENT_PERMISSIONS = [
        # Typically granted with `roles/resourcemanager.projectCreator`
        "resourcemanager.projects.create",

        # Typically granted with `roles/resourcemanager.folderViewer`
        "resourcemanager.folders.get",
    ]

    def __init__(self, folder_id, parent=False):
        self.folder_id = folder_id
        self.parent = parent
        self.permissions = []

        if self.parent:
            self.permissions += self.PARENT_PERMISSIONS

    def validate(self, credentials):
        service = discovery.build(
            'cloudresourcemanager', 'v2',
            credentials=credentials
        )

        body = {"permissions": self.permissions}
        resource = "folders/" + self.folder_id

        request = service.folders().testIamPermissions(
            resource=resource,
            body=body)
        response = request.execute()

        req = Requirements(
            "Service account permissions on parent folder",
            resource,
            self.permissions,
            response["permissions"],
        )

        return req.asdict()


class HostVpcProjectPermissions:
    ALL_PERMISSIONS = [
        # Typically granted with 'roles/resourcemanager.projectIamAdmin'
        "resourcemanager.projects.setIamPolicy",
    ]

    def __init__(self, project_id):
        self.project_id = project_id
        self.permissions = self.ALL_PERMISSIONS[:]

    def validate(self, credentials):
        service = discovery.build(
            'cloudresourcemanager', 'v1',
            credentials=credentials
        )

        body = {"permissions": self.permissions}
        resource = self.project_id

        request = service.projects().testIamPermissions(
            resource=resource,
            body=body)
        response = request.execute()

        req = Requirements(
            "Service account permissions on host VPC project",
            resource,
            self.permissions,
            response["permissions"],
        )

        return req.asdict()


class SeedProjectServices:
    """
    Test that the project containing the service project has enabled the
    required APIs.
    """

    REQUIRED_APIS = [
        "admin.googleapis.com",
        "appengine.googleapis.com",
        "iam.googleapis.com",
        "cloudbilling.googleapis.com",
        "cloudresourcemanager.googleapis.com",
    ]

    def __init__(self, project_id):
        self.project_id = project_id

    def validate(self, credentials):
        service = discovery.build(
            'serviceusage', 'v1',
            credentials=credentials
        )

        parent = "projects/" + self.project_id
        request = service.services().list(
            parent=parent,
            filter='state:ENABLED'
        )

        response = request.execute()

        enabled = [
            enabled_svc['config']['name']
            for enabled_svc in response['services']
        ]

        req = Requirements(
            "Required APIs on service account project",
            parent,
            self.REQUIRED_APIS,
            enabled,
        )

        return req.asdict()


class BillingAccount:
    """
    Test that the service account is able to link the billing account to
    projects.
    """

    REQUIRED_PERMISSIONS = [
        "billing.resourceAssociations.create"
    ]

    def __init__(self, billing_account):
        self.billing_account = billing_account

    def validate(self, credentials):
        service = discovery.build(
            'cloudbilling', 'v1',
            credentials=credentials
        )

        body = {"permissions": self.REQUIRED_PERMISSIONS}
        resource = "billingAccounts/" + self.billing_account

        request = service.billingAccounts().testIamPermissions(
            resource=resource,
            body=body)
        response = request.execute()

        req = Requirements(
            "Service account permissions on billing account",
            resource,
            self.REQUIRED_PERMISSIONS,
            response["permissions"],
        )

        return req.asdict()


def setup():
    logging.basicConfig()
    logging.getLogger().setLevel(logging.WARN)

    cache_log = logging.getLogger('googleapiclient.discovery_cache')
    cache_log.setLevel(logging.ERROR)

    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.DEBUG)
    requests_log.propagate = True


def get_credentials(credentials_path):
    credentials = service_account.Credentials.from_service_account_file(
        credentials_path)

    return credentials


class EmptyStrAction(argparse.Action):
    """
    Convert empty string values parsed by argparse into None.
    """
    def __call__(self, parser, namespace, values, option_string=None):
        values = None if values == '' else values
        setattr(namespace, self.dest, values)


def argparser():
    parser = argparse.ArgumentParser(
        description="""Check that Project Factory preconditions are met on the
        provided service account, project parent, and billing account.
        """
    )

    parser.add_argument(
        '--verbose', required=False, default=False,
        help='Enable verbose logging'
    )
    parser.add_argument(
        '--credentials_path', required=True,
        help='The service account credentials to check'
    )
    parser.add_argument(
        '--billing_account', required=True,
        help='The billing account to be associated with a new project'
    )
    parser.add_argument(
        '--org_id', required=True, action=EmptyStrAction,
        help='The organization ID'
    )
    parser.add_argument(
        '--folder_id', required=False, action=EmptyStrAction,
        help='The folder ID where projects will be created'
    )
    parser.add_argument(
        '--shared_vpc', required=False, action=EmptyStrAction,
        help='The project ID of the shared VPC host'
    )

    return parser


def validators_for(opts, seed_project):
    """
    Given a set of CLI options, determine which preconditions we need
    to check and generate corresponding validators.
    """
    validators = [
        SeedProjectServices(seed_project),
        BillingAccount(opts.billing_account),
    ]

    if opts.shared_vpc is not None:
        host_vpc_validator = HostVpcProjectPermissions(opts.shared_vpc)
        validators.append(host_vpc_validator)
        has_shared_vpc = True
    else:
        has_shared_vpc = False

    org_validator = OrgPermissions(opts.org_id,
                                   parent=True,
                                   shared_vpc=has_shared_vpc)
    validators.append(org_validator)
    return validators


def main(argv):
    opts = argparser().parse_args(argv[1:])
    credentials = get_credentials(opts.credentials_path)
    validators = validators_for(opts, credentials.project_id)

    results = []
    for validator in validators:
        results.append(validator.validate(credentials))

    retcode = 0
    for result in results:
        if len(result["unsatisfied"]) > 0:
            retcode = 1

    if retcode == 1 or opts.verbose:
        s = json.dumps(results, sys.stdout, indent=4)
        print(s)

    return retcode


if __name__ == "__main__":
    setup()
    retcode = main(sys.argv)
    sys.exit(retcode)
