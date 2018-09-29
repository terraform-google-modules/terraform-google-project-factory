#!/usr/bin/env python3

import unittest
import os
import sys
sys.path.append(
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            '../../helpers/')))

import migrate  # noqa: E402

TERRAFORM_STATE_LIST = """google_project_iam_member.additive_sa_role
google_project_iam_member.additive_shared_vpc_role
google_service_account.extra_service_account
google_service_account_iam_member.additive_service_account_grant_to_group
module.project-factory.google_compute_default_service_account.default
module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment
module.project-factory.google_project.project
module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]
module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]
module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]
module.project-factory.google_project_iam_member.controlling_group_vpc_membership[3]
module.project-factory.google_project_iam_member.default_service_account_membership
module.project-factory.google_project_iam_member.gke_host_agent
module.project-factory.google_project_iam_member.gsuite_group_role
module.project-factory.google_project_service.project_services[0]
module.project-factory.google_project_service.project_services[1]
module.project-factory.google_project_usage_export_bucket.usage_report_export
module.project-factory.google_service_account.default_service_account
module.project-factory.google_service_account_iam_member.service_account_grant_to_group
module.project-factory.null_data_source.data_final_group_email
module.project-factory.null_data_source.data_given_group_email
module.project-factory.null_data_source.data_group_email_format
module.project-factory.null_resource.delete_default_compute_service_account
module.project-factory.random_id.random_project_id_suffix"""


class TestTerraformModule(unittest.TestCase):
    def setUp(self):
        self.resources = [
            migrate.TerraformResource.from_path(path)
            for path in TERRAFORM_STATE_LIST.split("\n")
        ]

        self.module = migrate.TerraformModule(
            'module.project-factory',
            self.resources)

    def test_has_resource(self):
        assert self.module.has_resource('google_project', 'project')
        assert self.module.has_resource(None, 'project')
        assert self.module.has_resource('google_project', None)
        assert self.module.has_resource(None, None)

    def test_has_resource_empty(self):
        assert self.module.has_resource('google_compute_instance', None) is False

    def test_get_resources(self):
        expected = [resource for resource in self.resources
                    if resource.resource_type == 'google_project_iam_member']
        actual = self.module.get_resources('google_project_iam_member', None)
        assert actual == expected

    def test_get_resources_empty(self):
        actual = self.module.get_resources('google_compute_instance', None)
        assert actual == []


class TestTerraformResource(unittest.TestCase):

    def test_resource_init(self):
        resource = migrate.TerraformResource('', 'google_project', 'project')
        assert resource.module == ''
        assert resource.resource_type == 'google_project'
        assert resource.name == 'project'

    def test_resource_path_no_module(self):
        resource = migrate.TerraformResource('', 'google_project', 'project')
        assert resource.path() == 'google_project.project'

    def test_resource_path_with_module(self):
        resource = migrate.TerraformResource('module.project-factory', 'google_project', 'project')
        expected = 'module.project-factory.google_project.project'
        actual = resource.path()
        assert expected == actual


if __name__ == "__main__":
    unittest.main()
