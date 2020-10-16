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
            '../../../helpers/preconditions')))

import preconditions  # noqa: E402


class TestRequirements(unittest.TestCase):
    def setUp(self):
        self.required = [
            "admin.googleapis.com",
            "appengine.googleapis.com",
            "cloudbilling.googleapis.com",
            "cloudresourcemanager.googleapis.com",
            "iam.googleapis.com",
        ]
        self.required.sort()

    def test_is_satisfied(self):
        req = preconditions.Requirements(
            "seed project APIs",
            "projects/test-host-e503",
            self.required,
            [
                "admin.googleapis.com",
                "appengine.googleapis.com",
                "cloudbilling.googleapis.com",
                "cloudresourcemanager.googleapis.com",
                "iam.googleapis.com",
            ],
        )

        self.assertTrue(req.is_satisfied())

        satisfied = req.satisfied()
        satisfied.sort()

        self.assertEqual(self.required, satisfied)

    def test_extra_is_satisfied(self):
        req = preconditions.Requirements(
            "seed project APIs",
            "projects/test-host-e503",
            self.required,
            [
                "iam.googleapis.com",
                "admin.googleapis.com",
                "cloudbilling.googleapis.com",
                "cloudresourcemanager.googleapis.com",
                "compute.googleapis.com",
                "container.googleapis.com",
                "appengine.googleapis.com",
            ],
        )

        self.assertTrue(req.is_satisfied())

        satisfied = req.satisfied()
        satisfied.sort()

        self.assertEqual(self.required, satisfied)

    def test_is_not_satisfied(self):
        req = preconditions.Requirements(
            "seed project APIs",
            "projects/test-host-e503",
            self.required,
            [
                "iam.googleapis.com",
                "admin.googleapis.com",
                "appengine.googleapis.com",
            ],
        )

        self.assertFalse(req.is_satisfied())

    def test_empty_required(self):
        req = preconditions.Requirements(
            "seed project APIs",
            "projects/test-host-e503",
            [],  # Empty list of required permissions
            [],
        )

        self.assertTrue(req.is_satisfied())


class TestOrgPermissions(unittest.TestCase):
    def test_base_permissions(self):
        org_perms = preconditions.OrgPermissions("1234567890")
        self.assertEqual(org_perms.permissions, [])

    def test_shared_vpc_permissions(self):
        org_perms = preconditions.OrgPermissions("1234567890", shared_vpc=True)
        self.assertEqual(
            org_perms.permissions,
            [
                "compute.subnetworks.setIamPolicy",
                "compute.organizations.enableXpnResource",
            ]
        )

    def test_parent_permissions(self):
        org_perms = preconditions.OrgPermissions("1234567890", parent=True)
        self.assertEqual(
            org_perms.permissions,
            [
                "resourcemanager.projects.create"
            ]
        )


class TestFolderPermissions(unittest.TestCase):
    def test_base_permissions(self):
        folder_perms = preconditions.FolderPermissions("1234567890")
        self.assertEqual(folder_perms.permissions, [])

    def test_parent_permissions(self):
        folder_perms = preconditions.FolderPermissions(
            "1234567890",
            parent=True
        )
        self.assertEqual(
            folder_perms.permissions,
            [
                "resourcemanager.projects.create",
            ]
        )


if __name__ == "__main__":
    unittest.main()
