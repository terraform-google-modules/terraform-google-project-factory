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
  credentials_file_path = var.credentials_path
  subnet_01             = "${var.network_name}-subnet-01"
  subnet_02             = "${var.network_name}-subnet-02"
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  credentials = file(local.credentials_file_path)
  version     = "~> 2.7.0"
}

provider "google-beta" {
  credentials = file(local.credentials_file_path)
  version     = "~> 2.7.0"
}

/******************************************
  Host Project Creation
 *****************************************/
module "host-project" {
  source            = "../../"
  random_project_id = true
  name              = var.host_project_name
  org_id            = var.organization_id
  billing_account   = var.billing_account
  credentials_path  = local.credentials_file_path
}

/******************************************
  Network Creation
 *****************************************/
module "vpc" {
  # TODO: Switch to released version once
  # https://github.com/terraform-google-modules/terraform-google-network/pull/47
  # is merged and released.  This is here to fix the `Error: Unsupported block
  # type` on the `triggers` block in network's main.tf file.
  #
  # source  = "terraform-google-modules/network/google"
  # version = "0.8.0"
  source = "git::https://github.com/terraform-google-modules/terraform-google-network.git?ref=master"

  project_id   = module.host-project.project_id
  network_name = var.network_name

  delete_default_internet_gateway_routes = true
  shared_vpc_host                        = true

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
