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
  int_required_project_roles = [
    "roles/owner",
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/billing.projectManager",
  ]

  int_required_folder_roles = [
    "roles/owner",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.folderIamAdmin",
    "roles/billing.projectManager",
  ]
}

resource "google_service_account" "int_test" {
  project      = module.pfactory_project.project_id
  account_id   = "pfactory-int-test"
  display_name = "pfactory-int-test"
}

resource "google_project_iam_member" "int_test_project" {
  count = length(local.int_required_project_roles)

  project = module.pfactory_project.project_id
  role    = local.int_required_project_roles[count.index]
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_folder_iam_member" "int_test_folder" {
  count = length(local.int_required_folder_roles)

  folder = google_folder.ci_pfactory_folder.name
  role   = local.int_required_folder_roles[count.index]
  member = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_test.id
}
