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
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.30"
}

provider "gsuite" {
  impersonated_user_email = var.gsuite_admin_account

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]

  version = "~> 0.1.12"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

locals {
  subnet_name_01              = "pf-test-subnet-10-${var.random_string_for_testing}"
  shared_vpc_subnet_name_01   = module.vpc.subnets_names[0]
  shared_vpc_subnet_region_01 = module.vpc.subnets_regions[0]

  subnet_name_02              = "pf-test-subnet-20-${var.random_string_for_testing}-20"
  shared_vpc_subnet_name_02   = module.vpc.subnets_names[1]
  shared_vpc_subnet_region_02 = module.vpc.subnets_regions[1]

  shared_vpc_subnets = [
    "projects/${var.shared_vpc}/regions/${local.shared_vpc_subnet_region_01}/subnetworks/${local.shared_vpc_subnet_name_01}",
    "https://www.googleapis.com/compute/v1/projects/${var.shared_vpc}/regions/${local.shared_vpc_subnet_region_02}/subnetworks/${local.shared_vpc_subnet_name_02}",
  ]
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0"

  network_name = "pf-test-int-full-${var.random_string_for_testing}"
  project_id   = var.shared_vpc

  # The provided project must already be a Shared VPC host
  shared_vpc_host = false

  subnets = [
    {
      subnet_name   = local.subnet_name_01
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-east4"
    },
    {
      subnet_name   = local.subnet_name_02
      subnet_ip     = "10.10.20.0/24"
      subnet_region = "us-east1"
    },
  ]

  secondary_ranges = {
    "${local.subnet_name_01}" = [
      {
        range_name    = "${local.subnet_name_01}-secondary"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]
    "${local.subnet_name_02}" = [
      {
        range_name    = "${local.subnet_name_02}-secondary"
        ip_cidr_range = "192.168.74.0/24"
      },
    ]
  }
}

module "project-factory" {
  source = "../../../modules/gsuite_enabled"

  name              = "pf-ci-test-full-name-${var.random_string_for_testing}"
  random_project_id = false
  project_id        = "pf-ci-test-full-id-${var.random_string_for_testing}"

  domain                            = var.domain
  org_id                            = var.org_id
  folder_id                         = var.folder_id
  usage_bucket_name                 = var.usage_bucket_name
  usage_bucket_prefix               = var.usage_bucket_prefix
  billing_account                   = var.billing_account
  create_group                      = true
  group_role                        = var.group_role
  group_name                        = var.group_name
  shared_vpc                        = var.shared_vpc
  enable_shared_vpc_service_project = true
  shared_vpc_subnets                = local.shared_vpc_subnets
  sa_role                           = var.sa_role
  sa_group                          = var.sa_group
  lien                              = true

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataflow.googleapis.com",
  ]

  default_service_account     = "DELETE"
  disable_services_on_destroy = false
}

resource "google_service_account" "extra_service_account" {
  project    = module.project-factory.project_id
  account_id = "extra-service-account"
}

resource "google_project_iam_member" "additive_sa_role" {
  count   = var.sa_role != "" ? 1 : 0
  project = module.project-factory.project_id
  role    = var.sa_role
  member  = "serviceAccount:${google_service_account.extra_service_account.email}"
}

resource "google_project_iam_member" "additive_shared_vpc_role" {
  count   = var.shared_vpc != "" ? 1 : 0
  project = var.shared_vpc
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.extra_service_account.email}"
}

resource "google_service_account_iam_member" "additive_service_account_grant_to_group" {
  service_account_id = "projects/${module.project-factory.project_id}/serviceAccounts/${module.project-factory.service_account_email}"

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.extra_service_account.email}"
}
