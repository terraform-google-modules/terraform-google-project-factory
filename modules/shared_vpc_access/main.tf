/**
 * Copyright 2020 Google LLC
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

data "google_project" "service_project" {
  project_id = var.service_project_id
}

locals {
  gke_shared_vpc_enabled = contains(var.active_apis, "container.googleapis.com")
  gke_s_account = local.gke_shared_vpc_enabled ? format(
    "service-%s@container-engine-robot.iam.gserviceaccount.com",
    data.google_project.service_project.number,
  ) : ""
  dataproc_shared_vpc_enabled = contains(var.active_apis, "dataproc.googleapis.com")
  dataproc_s_account = local.dataproc_shared_vpc_enabled ? format(
    "service-%s@dataproc-accounts.iam.gserviceaccount.com",
    data.google_project.service_project.number
  ) : ""
  active_api_s_accounts = compact([local.gke_s_account, local.dataproc_s_account])
}

/******************************************
  compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
 *****************************************/
resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
  provider = google-beta
  count    = local.gke_shared_vpc_enabled && length(var.shared_vpc_subnets) != 0 ? length(var.shared_vpc_subnets) : 0
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
  project = var.host_project_id
  member  = format("serviceAccount:%s", local.gke_s_account)
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC
  See:https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count   = local.gke_shared_vpc_enabled ? 1 : 0
  project = var.host_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = format("serviceAccount:%s", local.gke_s_account)
}

/******************************************
  compute.networkUser role granted to dataproc service account for dataproc on shared VPC subnets
  See: https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/network#creating_a_cluster_that_uses_a_vpc_network_in_another_project
 *****************************************/
resource "google_project_iam_member" "dataproc_shared_vpc_network_user" {
  count   = local.dataproc_shared_vpc_enabled ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = format("serviceAccount:%s", local.dataproc_s_account)
}
