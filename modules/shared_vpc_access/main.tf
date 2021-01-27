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
  count      = var.lookup_project_numbers ? 1 : 0
  project_id = var.service_project_id
}

locals {
  service_project_number = var.lookup_project_numbers ? data.google_project.service_project[0].number : var.service_project_number
  apis = {
    "container.googleapis.com" : format("service-%s@container-engine-robot.iam.gserviceaccount.com", local.service_project_number),
    "dataproc.googleapis.com" : format("service-%s@dataproc-accounts.iam.gserviceaccount.com", local.service_project_number),
    "dataflow.googleapis.com" : format("service-%s@dataflow-service-producer-prod.iam.gserviceaccount.com", local.service_project_number),
  }
  gke_shared_vpc_enabled = contains(var.active_apis, "container.googleapis.com")
  active_apis            = setintersection(keys(local.apis), var.active_apis)
  subnetwork_api         = length(var.shared_vpc_subnets) != 0 ? tolist(setproduct(local.active_apis, var.shared_vpc_subnets)) : []
}

/******************************************
  if "container.googleapis.com" compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
  if "dataproc.googleapis.com" compute.networkUser role granted to dataproc service account for dataproc on shared VPC subnets
  if "dataflow.googleapis.com" compute.networkUser role granted to dataflow  service account for Dataflow on shared VPC subnets
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
       https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#cloud_dataflow_service_account
 *****************************************/
resource "google_compute_subnetwork_iam_member" "service_shared_vpc_subnet_users" {
  provider = google-beta
  count    = length(local.subnetwork_api)
  subnetwork = element(
    split("/", local.subnetwork_api[count.index][1]),
    index(
      split("/", local.subnetwork_api[count.index][1]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", local.subnetwork_api[count.index][1]),
    index(split("/", local.subnetwork_api[count.index][1]), "regions") + 1,
  )
  project = var.host_project_id
  member  = format("serviceAccount:%s", local.apis[local.subnetwork_api[count.index][0]])
}

/******************************************
 if "container.googleapis.com" compute.networkUser role granted to GKE service account for GKE on shared VPC Project if no subnets defined
 if "dataproc.googleapis.com" compute.networkUser role granted to dataproc service account for Dataproc on shared VPC Project if no subnets defined
 if "dataflow.googleapis.com" compute.networkUser role granted to dataflow service account for Dataflow on shared VPC Project if no subnets defined
 *****************************************/
resource "google_project_iam_member" "service_shared_vpc_user" {
  for_each = (length(var.shared_vpc_subnets) == 0) && var.enable_shared_vpc_service_project ? local.active_apis : []
  project  = var.host_project_id
  role     = "roles/compute.networkUser"
  member   = format("serviceAccount:%s", local.apis[each.value])
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC host project
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count   = local.gke_shared_vpc_enabled && var.enable_shared_vpc_service_project ? 1 : 0
  project = var.host_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = format("serviceAccount:%s", local.apis["container.googleapis.com"])
}

/******************************************
  roles/compute.securityAdmin role granted to GKE service account for GKE on shared VPC host project
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc#enabling_and_granting_roles
  and https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc#creating_additional_firewall_rules
 *****************************************/
resource "google_project_iam_member" "gke_security_admin" {
  count   = local.gke_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_services_security_admin_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.securityAdmin"
  member  = format("serviceAccount:%s", local.apis["container.googleapis.com"])
}
