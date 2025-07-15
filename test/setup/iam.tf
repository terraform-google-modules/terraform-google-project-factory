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
      "roles/servicenetworking.networksAdmin",
      "roles/iam.serviceAccountUser",
      "roles/logging.logWriter",
    ]
    shared_vpc_access = [
      "roles/compute.networkUser",
      "roles/iam.serviceAccountUser",
      "roles/logging.logWriter",
    ]
    quota_manager = [
      "roles/serviceusage.quotaViewer",
      "roles/logging.logWriter",
    ]
    project_services = [
      "roles/serviceusage.serviceUsageAdmin",
      "roles/logging.logWriter",
    ]
    gsuite_group = [
      "roles/cloudidentity.groupAdmin",
      "roles/logging.logWriter",
    ]
    gsuite_enabled = [
      "roles/cloudidentity.groupMemberAdmin",
      "roles/logging.logWriter",
    ]
    fabric-project = [
      "roles/resourcemanager.projectIamAdmin",
      "roles/logging.logWriter",
    ]
    essential_contacts = [
      "roles/essentialcontacts.configEditor",
      "roles/logging.logWriter",
    ]
    core_project_factory = [
      "roles/resourcemanager.projectCreator",
      "roles/resourcemanager.projectDeleter",
      "roles/resourcemanager.projectIamAdmin",
      "roles/compute.networkUser",
      "roles/logging.logWriter",
    ]
    budget = [
      "roles/logging.logWriter",
    ]
    app_engine = [
      "roles/appengine.appAdmin",
      "roles/logging.logWriter",
    ]
    root = [
      "roles/resourcemanager.organizationAdmin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
      "roles/logging.logWriter",
    ]
  }

  int_required_project_roles = concat([
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/billing.projectManager",
  ], flatten(values(local.per_module_roles)))

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
