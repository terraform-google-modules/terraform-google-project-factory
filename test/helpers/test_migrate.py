#!/usr/bin/env python3

import os
import sys
sys.path.append(
        os.path.abspath(
            os.path.join(
                os.path.dirname(__file__),
                '../../helpers/')))

import unittest  # noqa: E402
import migrate  # noqa: E402


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
        resource = migrate.TerraformResource(
                'module.project-factory',
                'google_project',
                'project')
        expected = 'module.project-factory.google_project.project'
        actual = resource.path()
        assert expected == actual


if __name__ == "__main__":
    unittest.main()
