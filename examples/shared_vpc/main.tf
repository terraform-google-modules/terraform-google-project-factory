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

locals {
  subnet_01 = "${var.network_name}-subnet-01"
  subnet_02 = "${var.network_name}-subnet-02"
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.30"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/******************************************
  Host Project Creation
 *****************************************/
module "host-project" {
  source                         = "../../"
  random_project_id              = true
  name                           = var.host_project_name
  org_id                         = var.organization_id
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
}

/******************************************
  Network Creation
 *****************************************/
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5.0"

  project_id                             = module.host-project.project_id
  network_name                           = var.network_name
  delete_default_internet_gateway_routes = true

  subnets = [
    {
      subnet_name   = local.subnet_01
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-west1"
    },
    {
      subnet_name           = local.subnet_02
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    "${local.subnet_01}" = [
      {
        range_name    = "${local.subnet_01}-01"
        ip_cidr_range = "192.168.64.0/24"
      },
      {
        range_name    = "${local.subnet_01}-02"
        ip_cidr_range = "192.168.65.0/24"
      },
    ]

    "${local.subnet_02}" = [
      {
        range_name    = "${local.subnet_02}-01"
        ip_cidr_range = "192.168.66.0/24"
      },
    ]
  }
}

/******************************************
  Service Project Creation
 *****************************************/
module "service-project" {
  source = "../../modules/svpc_service_project"

  name              = var.service_project_name
  random_project_id = false

  org_id          = var.organization_id
  folder_id       = var.folder_id
  billing_account = var.billing_account

  shared_vpc         = module.host-project.project_id
  shared_vpc_subnets = module.vpc.subnets_self_links

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataproc.googleapis.com",
    "dataflow.googleapis.com",
  ]

  disable_services_on_destroy = false
}

/******************************************
  Second Service Project Creation
 *****************************************/
module "service-project-b" {
  source = "../../modules/svpc_service_project"

  name              = "b-${var.service_project_name}"
  random_project_id = false

  org_id          = var.organization_id
  folder_id       = var.folder_id
  billing_account = var.billing_account

  shared_vpc = module.host-project.project_id

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataproc.googleapis.com",
  ]

  activate_api_identities = [{
    api = "healthcare.googleapis.com"
    roles = [
      "roles/healthcare.serviceAgent",
      "roles/bigquery.jobUser",
    ]
  }]

  disable_services_on_destroy = false
}

/******************************************
  Third Service Project Creation
  To test the grant_services_network_role
 *****************************************/
module "service-project-c" {
  source = "../../modules/svpc_service_project"

  name              = "c-${var.service_project_name}"
  random_project_id = false

  org_id          = var.organization_id
  folder_id       = var.folder_id
  billing_account = var.billing_account

  shared_vpc = module.host-project.project_id

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataproc.googleapis.com",
  ]

  activate_api_identities = [{
    api = "healthcare.googleapis.com"
    roles = [
      "roles/healthcare.serviceAgent",
      "roles/bigquery.jobUser",
    ]
  }]

  disable_services_on_destroy = false
  grant_services_network_role = false
}

/******************************************
  Example dependency on service-project
 *****************************************/

resource "google_compute_address" "example_address" {
  project      = module.service-project.project_id
  region       = "us-west1"
  subnetwork   = module.vpc.subnets_self_links[0]
  name         = "test-address"
  address_type = "INTERNAL"
}
