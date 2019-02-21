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

import os
import sys
import unittest
sys.path.append(
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            '../../helpers/')))

import migrate  # noqa: E402

TERRAFORM_STATE_LIST = [
    "google_compute_instance.test",
    "google_project_iam_member.user-editor",
    "module.project-factory.google_compute_default_service_account.default",
    "module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[0]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[1]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[2]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1]",  # noqa: E501
    "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2]",  # noqa: E501
    "module.project-factory.google_organization.org",
    "module.project-factory.google_project.project",
    "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]",  # noqa: E501
    "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]",  # noqa: E501
    "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]",  # noqa: E501
    "module.project-factory.google_project_iam_member.gsuite_group_role",
    "module.project-factory.google_project_service.project_services",
    "module.project-factory.google_service_account.default_service_account",
    "module.project-factory.google_service_account_iam_member.service_account_grant_to_group",  # noqa: E501
    "module.project-factory.gsuite_group.group",
    "module.project-factory.gsuite_group_member.api_s_account_api_sa_group_member",  # noqa: E501
    "module.project-factory.null_data_source.data_final_group_email",
    "module.project-factory.null_data_source.data_given_group_email",
    "module.project-factory.null_data_source.data_group_email_format",
    "module.project-factory.null_resource.delete_default_compute_service_account",  # noqa: E501
    "module.project-factory.random_id.random_project_id_suffix",
]

TERRAFORM_MOVES = [
    (
        "module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[0]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[0]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[1]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[1]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[2]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[2]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1]",  # noqa: E501
    ),
    (
        "module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2]",  # noqa: E501
        "module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2]",  # noqa: E501
    ),
    (
        "module.project-factory.google_project.project",
        "module.project-factory.module.project-factory.google_project.main",
    ),
    (
        "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]",  # noqa: E501
        "module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]",  # noqa: E501
    ),
    (
        "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]",  # noqa: E501
        "module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]",  # noqa: E501
    ),
    (
        "module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]",  # noqa: E501
        "module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]",  # noqa: E501
    ),
    (
        "module.project-factory.google_project_iam_member.gsuite_group_role",
        "module.project-factory.module.project-factory.google_project_iam_member.gsuite_group_role",  # noqa: E501
    ),
    (
        "module.project-factory.google_project_service.project_services",
        "module.project-factory.module.project-factory.google_project_service.project_services",  # noqa: E501
    ),
    (
        "module.project-factory.google_service_account.default_service_account",  # noqa: E501
        "module.project-factory.module.project-factory.google_service_account.default_service_account",  # noqa: E501
    ),
    (
        "module.project-factory.google_service_account_iam_member.service_account_grant_to_group",  # noqa: E501
        "module.project-factory.module.project-factory.google_service_account_iam_member.service_account_grant_to_group",  # noqa: E501
    ),
    (
        "module.project-factory.null_resource.delete_default_compute_service_account",  # noqa: E501
        "module.project-factory.module.project-factory.null_resource.delete_default_compute_service_account",  # noqa: E501
    ),
    (
        "module.project-factory.random_id.random_project_id_suffix",
        "module.project-factory.module.project-factory.random_id.random_project_id_suffix",  # noqa: E501
    ),
]


# The following entities are data sources that are not part of the 1.0
# migration process and should not be present in the list of resource
# moves.
TERRAFORM_DROPPED_DATA_SOURCES = [
    (
        "module.project-factory.google_organization.org",
        "module.project-factory.module.project-factory.google_organization.org",  # noqa: E501
    ),
    (
        "module.project-factory.null_data_source.data_final_group_email",
        "module.project-factory.module.project-factory.null_data_source.data_final_group_email",  # noqa: E501
    ),
    (
        "module.project-factory.null_data_source.data_given_group_email",
        "module.project-factory.module.project-factory.null_data_source.data_given_group_email",  # noqa: E501
    ),
    (
        "module.project-factory.null_data_source.data_group_email_format",
        "module.project-factory.module.project-factory.null_data_source.data_group_email_format",  # noqa: E501
    ),
]


# The following entities are resources that were not part of the migration
# and should not be present in the list of resource moves.
TERRAFORM_UNMIGRATED_MOVES = [
    (
        "module.project-factory.gsuite_group.group",
        "module.project-factory.module.project-factory.gsuite_group.group",
    ),
    (
        "module.project-factory.gsuite_group_member.api_s_account_api_sa_group_member",  # noqa: E501
        "module.project-factory.module.project-factory.gsuite_group_member.api_s_account_api_sa_group_member",  # noqa: E501
    ),
]


class TestGSuiteMigration(unittest.TestCase):
    def setUp(self):
        self.resources = [
            migrate.TerraformResource.from_path(path)
            for path in TERRAFORM_STATE_LIST
        ]

        self.module = migrate.TerraformModule(
            'module.project-factory',
            self.resources)
        self.migration = migrate.GSuiteMigration(self.module)

    def test_moves(self):
        computed_moves = self.migration.moves()
        self.assertEqual(set(computed_moves), set(TERRAFORM_MOVES))

    def test_no_moves_of_data_sources(self):
        computed_moves = self.migration.moves()

        self.assertTrue(
            set(TERRAFORM_DROPPED_DATA_SOURCES).isdisjoint(computed_moves))

    def test_no_moves_of_unmigrated_resources(self):
        computed_moves = self.migration.moves()

        self.assertTrue(
            set(TERRAFORM_UNMIGRATED_MOVES).isdisjoint(computed_moves))

    def test_no_moves_outside_of_module(self):
        computed_moves = self.migration.moves()

        old_resources = [move[0] for move in computed_moves]
        self.assertFalse("google_compute_instance.test" in old_resources)
        self.assertFalse(
            "google_project_iam_member.user-editor" in old_resources)


class TestTerraformModule(unittest.TestCase):
    def setUp(self):
        self.resources = [
            migrate.TerraformResource.from_path(path)
            for path in TERRAFORM_STATE_LIST
        ]

        self.module = migrate.TerraformModule(
            'module.project-factory',
            self.resources)

    def test_has_resource(self):
        self.assertTrue(self.module.has_resource('google_project', 'project'))
        self.assertTrue(self.module.has_resource(None, 'project'))
        self.assertTrue(self.module.has_resource('google_project', None))
        self.assertTrue(self.module.has_resource(None, None))

    def test_has_resource_empty(self):
        self.assertFalse(
            self.module.has_resource('google_cloudiot_registry', None))

    def test_get_resources(self):
        expected = [resource for resource in self.resources
                    if resource.resource_type == 'google_project_iam_member']
        actual = self.module.get_resources('google_project_iam_member', None)
        self.assertEqual(actual, expected)

    def test_get_resources_empty(self):
        actual = self.module.get_resources('google_cloudiot_registry', None)
        self.assertTrue(len(actual) == 0)


class TestTerraformResource(unittest.TestCase):
    def test_root_resource_from_path(self):
        resource = migrate.TerraformResource.from_path(
            "google_project.project")
        self.assertEqual(resource.module, '')
        self.assertEqual(resource.resource_type, 'google_project')
        self.assertEqual(resource.name, 'project')

    def test_module_resource_from_path(self):
        resource = migrate.TerraformResource.from_path(
            "module.project-factory.google_project.project")
        self.assertEqual(resource.module, 'module.project-factory')
        self.assertEqual(resource.resource_type, 'google_project')
        self.assertEqual(resource.name, 'project')

    def test_invalid_resource_from_path(self):
        self.assertRaises(
            Exception,
            lambda: migrate.TerraformResource.from_path("not a resource path!")
        )

    def test_resource_init(self):
        resource = migrate.TerraformResource('', 'google_project', 'project')
        self.assertEqual(resource.module, '')
        self.assertEqual(resource.resource_type, 'google_project')
        self.assertEqual(resource.name, 'project')

    def test_resource_path_no_module(self):
        resource = migrate.TerraformResource('', 'google_project', 'project')
        self.assertEqual(resource.path(), 'google_project.project')

    def test_resource_path_with_module(self):
        resource = migrate.TerraformResource('module.project-factory',
                                             'google_project', 'project')
        expected = 'module.project-factory.google_project.project'
        actual = resource.path()
        self.assertEqual(expected, actual)


if __name__ == "__main__":
    unittest.main()
