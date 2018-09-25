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

provider "gsuite" {
  credentials             = "${file(var.credentials_path)}"
  impersonated_user_email = "${var.gsuite_admin_account}"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]
}

module "project-factory" {
  source              = "../../../"
  name                = "${var.name}"
  random_project_id   = "${var.random_project_id}"
  domain              = "${var.domain}"
  org_id              = "${var.org_id}"
  folder_id           = "${var.folder_id}"
  usage_bucket_name   = "${var.usage_bucket_name}"
  usage_bucket_prefix = "${var.usage_bucket_prefix}"
  billing_account     = "${var.billing_account}"
  create_group        = "${var.create_group}"
  group_role          = "${var.group_role}"
  group_name          = "${var.group_name}"
  shared_vpc          = "${var.shared_vpc}"
  sa_role             = "${var.sa_role}"
  sa_group            = "${var.sa_group}"
  activate_apis       = "${var.activate_apis}"
  credentials_path    = "${var.credentials_path}"

  app_engine {
    location_id = "${var.region}"
    auth_domain = "${var.domain}"

    feature_settings = [
      {
        split_health_checks = false
      },
    ]
  }
}

resource "google_service_account" "extra_service_account" {
  project    = "${module.project-factory.project_id}"
  account_id = "extra-service-account"
}

resource "google_project_iam_member" "additive_sa_role" {
  count   = "${var.sa_role != "" ? 1 : 0}"
  project = "${module.project-factory.project_id}"
  role    = "${var.sa_role}"
  member  = "serviceAccount:${google_service_account.extra_service_account.email}"
}

resource "google_project_iam_member" "additive_shared_vpc_role" {
  count   = "${var.shared_vpc != "" ? 1 : 0}"
  project = "${var.shared_vpc}"
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.extra_service_account.email}"
}

resource "google_service_account_iam_member" "additive_service_account_grant_to_group" {
  count = "${module.project-factory.group_email != "" ? 1 : 0}"

  service_account_id = "projects/${module.project-factory.project_id}/serviceAccounts/${module.project-factory.service_account_email}"

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.extra_service_account.email}"
}
