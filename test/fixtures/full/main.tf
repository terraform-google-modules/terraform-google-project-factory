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
  version = "~> 1.19"
}

provider "gsuite" {
  credentials             = "${file(var.credentials_path)}"
  impersonated_user_email = "${var.gsuite_admin_account}"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]

  version = "~> 0.1.9"
}

locals {
  shared_vpc_subnets = ["projects/${var.shared_vpc}/regions/${google_compute_subnetwork.subnet-01.region}/subnetworks/${google_compute_subnetwork.subnet-01.name}"]
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_compute_network" "network" {
  name                    = "pf-test-int-full-${random_string.suffix.result}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "true"
  project                 = "${var.shared_vpc}"
}

resource "google_compute_subnetwork" "subnet-01" {
  name          = "subnet-01"
  ip_cidr_range = "10.10.10.0/24"
  region        = "us-east4"
  network       = "${google_compute_network.network.name}"
  project       = "${var.shared_vpc}"
}

module "project-factory" {
  source              = "../../../"
  name                = "pf-test-int-full-${random_string.suffix.result}"
  random_project_id   = "true"
  org_id              = "${var.org_id}"
  folder_id           = "${var.folder_id}"
  usage_bucket_name   = "${var.usage_bucket_name}"
  usage_bucket_prefix = "${var.usage_bucket_prefix}"
  billing_account     = "${var.billing_account}"
  create_group        = "${var.create_group}"
  group_role          = "${var.group_role}"
  group_name          = "${var.group_name}"
  shared_vpc          = "${var.shared_vpc}"
  shared_vpc_subnets  = "${local.shared_vpc_subnets}"
  sa_role             = "${var.sa_role}"
  sa_group            = "${var.sa_group}"
  credentials_path    = "${var.credentials_path}"
  lien                = "true"

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]

  disable_services_on_destroy = "false"

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
