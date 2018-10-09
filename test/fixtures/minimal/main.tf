/**
 * Copyright 2018 Google LLC
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

provider "google" {
  credentials = "${file(var.credentials_path)}"
}

module "project-factory" {
  source              = "../../../"
  name                = "${var.name}-minimal"
  random_project_id   = "${var.random_project_id}"
  org_id              = "${var.org_id}"
  folder_id           = "${var.folder_id}"
  billing_account     = "${var.billing_account}"
  activate_apis       = "${var.activate_apis}"
  credentials_path    = "${var.credentials_path}"
}

resource "google_service_account" "extra_service_account" {
  project    = "${module.project-factory.project_id}"
  account_id = "extra-service-account"
}

resource "google_service_account_iam_member" "additive_service_account_grant_to_group" {
  service_account_id = "projects/${module.project-factory.project_id}/serviceAccounts/${module.project-factory.service_account_email}"

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.extra_service_account.email}"
}
