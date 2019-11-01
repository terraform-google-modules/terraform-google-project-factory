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
  shared_vpc_users = compact(
    [
      var.group_id,
      var.s_account_fmt,
      var.api_s_account_fmt,
      var.gke_s_account_fmt,
    ],
  )

  # Workaround for https://github.com/hashicorp/terraform/issues/10857
  shared_vpc_users_length = var.gke_shared_vpc_enabled ? 4 : 3
}

/*******************************************
  Shared VPC Subnets names validation
*******************************************/

resource "null_resource" "shared_vpc_subnet_invalid_name" {
  count = length(var.shared_vpc_subnets)

  triggers = {
    name = replace(
      var.shared_vpc_subnets[count.index],
      "/(https://www.googleapis.com/compute/v1/)?projects/[a-z0-9-]+/regions/[a-z0-9-]+/subnetworks/[a-z0-9-]+/",
      "",
    )
  }
}

resource "null_resource" "check_if_shared_vpc_subnets_contains_items_with_invalid_name" {
  count = length(
    compact(null_resource.shared_vpc_subnet_invalid_name.*.triggers.name),
  ) == 0 ? 0 : 1

  provisioner "local-exec" {
    command     = "false"
    interpreter = ["bash", "-c"]
  }
}

/******************************************
  Shared VPC configuration
 *****************************************/
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  count           = var.shared_vpc_enabled ? 1 : 0
  host_project    = var.host_project
  service_project = var.service_project
}

/************************************************************************************************
  compute.networkUser role granted to G Suite group, APIs Service account,
   Project Service Account, and GKE Service Account on shared VPC
 ************************************************************************************************/
resource "google_project_iam_member" "controlling_group_vpc_membership" {
  count = var.shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) == 0 ? local.shared_vpc_users_length : 0

  project = var.host_project
  role    = "roles/compute.networkUser"
  member  = element(local.shared_vpc_users, count.index)
}

/*************************************************************************************
  compute.networkUser role granted to Project Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta
  count    = var.shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.host_project
  member  = var.s_account_fmt
}

/*************************************************************************************
  compute.networkUser role granted to G Suite group on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "group_role_to_vpc_subnets" {
  provider = google-beta

  count = var.shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) > 0 && var.manage_group ? length(var.shared_vpc_subnets) : 0
  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  member  = var.group_id
  project = var.host_project
}

/*************************************************************************************
  compute.networkUser role granted to APIs Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "apis_service_account_role_to_vpc_subnets" {
  provider = google-beta

  count = var.shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0
  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.host_project
  member  = var.api_s_account_fmt
}

/******************************************
  compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
 *****************************************/
resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
  provider = google-beta
  count    = var.gke_shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) != 0 ? length(var.shared_vpc_subnets) : 0
  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.host_project
  member  = var.gke_s_account_fmt
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count   = var.gke_shared_vpc_enabled ? 1 : 0
  project = var.host_project
  role    = "roles/container.hostServiceAgentUser"
  member  = var.gke_s_account_fmt
}

