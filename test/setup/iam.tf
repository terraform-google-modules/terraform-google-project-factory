/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  per_module_roles = {
    svpc_service_project = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    shared_vpc_access = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    quota_manager = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    project_services = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    gsuite_group = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    gsuite_enabled = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    fabric-project = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    essential_contacts = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    core_project_factory = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    budget = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    app_engine = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
    root = [
      "roles/compute.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/storage.admin",
      "roles/iam.serviceAccountUser",
      "roles/billing.projectManager",
    ]
  }

  int_required_project_roles = tolist(toset(concat([
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/billing.projectManager",
  ], flatten(values(local.per_module_roles)))))

  int_required_folder_roles = [
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.folderIamAdmin",
    "roles/billing.projectManager",
    "roles/compute.xpnAdmin"
  ]

  int_required_org_roles = [
    "roles/accesscontextmanager.policyAdmin",
    "roles/resourcemanager.organizationViewer",
    # CRUD tags.
    "roles/resourcemanager.tagAdmin",
    # Binding tags to resources.
    "roles/resourcemanager.tagUser"
  ]
}

resource "google_service_account" "int_test" {
  project      = module.pfactory_project.project_id
  account_id   = "pfactory-int-test"
  display_name = "pfactory-int-test"
}

resource "google_project_iam_member" "int_test_project" {
  for_each = toset(local.int_required_project_roles)

  project = module.pfactory_project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_folder_iam_member" "int_test_folder" {
  for_each = toset(local.int_required_folder_roles)

  folder = google_folder.ci_pfactory_folder.name
  role   = each.value
  member = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_organization_iam_member" "int_test_org" {
  for_each = toset(local.int_required_org_roles)

  org_id = var.org_id
  role   = each.value
  member = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_test.id
}

resource "google_billing_account_iam_member" "int_billing_admin" {
  for_each           = toset(["roles/billing.user", "roles/billing.costsManager"])
  billing_account_id = var.billing_account
  role               = each.value
  member             = "serviceAccount:${google_service_account.int_test.email}"
}
