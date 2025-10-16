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
    "container.googleapis.com" : {
      service_account = format("service-%s@container-engine-robot.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "dataproc.googleapis.com" : {
      service_account = format("service-%s@dataproc-accounts.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    },
    "dataflow.googleapis.com" : {
      service_account = format("service-%s@dataflow-service-producer-prod.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    },
    "datafusion.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-datafusion.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkViewer"
    },
    "composer.googleapis.com" : {
      service_account = format("service-%s@cloudcomposer-accounts.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "vpcaccess.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-vpcaccess.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "datastream.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-datastream.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "notebooks.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-notebooks.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "networkconnectivity.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-networkconnectivity.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "run.googleapis.com" : {
      service_account = format("service-%s@serverless-robot-prod.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "aiplatform.googleapis.com" : {
      service_account = format("service-%s@gcp-sa-aiplatform.iam.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
    "cloudbuild.googleapis.com" : {
      service_account = format("%s@cloudbuild.gserviceaccount.com", local.service_project_number)
      role            = "roles/compute.networkUser"
    }
  }
  gke_shared_vpc_enabled          = contains(var.active_apis, "container.googleapis.com")
  composer_shared_vpc_enabled     = contains(var.active_apis, "composer.googleapis.com")
  datastream_shared_vpc_enabled   = contains(var.active_apis, "datastream.googleapis.com")
  datafusion_shared_vpc_enabled   = contains(var.active_apis, "datafusion.googleapis.com")
  managedkafka_shared_vpc_enabled = contains(var.active_apis, "managedkafka.googleapis.com")
  cloudrun_shared_vpc_enabled     = contains(var.active_apis, "run.googleapis.com")
  active_apis                     = [for api in keys(local.apis) : api if contains(var.active_apis, api)]
  # Can't use setproduct due to https://github.com/terraform-google-modules/terraform-google-project-factory/issues/635
  subnetwork_api = length(var.shared_vpc_subnets) != 0 ? flatten([
    for i, api in local.active_apis : [for i, subnet in var.shared_vpc_subnets : "${api},${subnet}"]
  ]) : []
}

/******************************************
  if "container.googleapis.com" compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
  if "dataproc.googleapis.com" compute.networkUser role granted to dataproc service account for dataproc on shared VPC subnets
  if "dataflow.googleapis.com" compute.networkUser role granted to dataflow service account for Dataflow on shared VPC subnets
  if "datafusion.googleapis.com" compute.networkViewer role granted to datafusion service account for Data Fusion on shared VPC subnets
  if "composer.googleapis.com" compute.networkUser role granted to composer service account for Composer on shared VPC subnets
  if "notebooks.googleapis.com" compute.networkUser role granted to notebooks service account for Notebooks on shared VPC Project
  if "networkconnectivity.googleapis.com" compute.networkUser role granted to notebooks service account for Network Connectivity on shared VPC Project
  if "vpcaccess.googleapis.com" compute.networkUser role granted to Serverless VPC Access Service Agent on shared VPC subnets
  if "run.googleapis.com" compute.networkUser role granted to Cloud Run service account for Cloud Run on shared VPC subnets
  if "aiplatform.googleapis.com" compute.networkUser role granted to Vertex AI service agent on shared VPC subnets
  if "cloudbuild.googleapis.com" compute.networkUser role granted to cloudbuild service agent on shared VPC subnets
  See: https://cloud.google.com/vpc/docs/configure-service-connection-policies#configure-host-project
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
  See: https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#cloud_dataflow_service_account
  See: https://cloud.google.com/composer/docs/how-to/managing/configuring-shared-vpc
  See: https://cloud.google.com/run/docs/configuring/connecting-shared-vpc#grant-permissions
  See: https://cloud.google.com/run/docs/configuring/shared-vpc-direct-vpc#iam
  see: https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/private-service-connect-interface#using-with-vpc-shared-vpc
 *****************************************/
resource "google_compute_subnetwork_iam_member" "service_shared_vpc_subnet_users" {
  provider = google-beta
  count    = var.grant_network_role ? length(local.subnetwork_api) : 0
  subnetwork = element(
    split("/", split(",", local.subnetwork_api[count.index])[1]),
    index(
      split("/", split(",", local.subnetwork_api[count.index])[1]),
      "subnetworks",
    ) + 1,
  )
  role = local.apis[split(",", local.subnetwork_api[count.index])[0]].role
  region = element(
    split("/", split(",", local.subnetwork_api[count.index])[1]),
    index(split("/", split(",", local.subnetwork_api[count.index])[1]), "regions") + 1,
  )
  project = var.host_project_id
  member  = format("serviceAccount:%s", local.apis[split(",", local.subnetwork_api[count.index])[0]].service_account)
}

/******************************************
  if "container.googleapis.com" compute.networkUser role granted to Google API service account for GKE on shared VPC subnets
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc#enabling_and_granting_roles
 *****************************************/
resource "google_compute_subnetwork_iam_member" "cloudservices_shared_vpc_subnet_users" {
  provider = google-beta
  count    = local.gke_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? length(local.subnetwork_api) : 0
  subnetwork = element(
    split("/", split(",", local.subnetwork_api[count.index])[1]),
    index(
      split("/", split(",", local.subnetwork_api[count.index])[1]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", split(",", local.subnetwork_api[count.index])[1]),
    index(split("/", split(",", local.subnetwork_api[count.index])[1]), "regions") + 1,
  )
  project = var.host_project_id
  member  = format("serviceAccount:%s@cloudservices.gserviceaccount.com", local.service_project_number)
}

/******************************************
 if "container.googleapis.com" compute.networkUser role granted to GKE service account for GKE on shared VPC Project if no subnets defined
 if "dataproc.googleapis.com" compute.networkUser role granted to dataproc service account for Dataproc on shared VPC Project if no subnets defined
 if "dataflow.googleapis.com" compute.networkUser role granted to dataflow service account for Dataflow on shared VPC Project if no subnets defined
 if "datafusion.googleapis.com" compute.networkViewer role granted to data fusion service account for Data Fusion on shared VPC Project if no subnets defined
 if "composer.googleapis.com" compute.networkUser role granted to composer service account for Composer on shared VPC Project if no subnets defined
 if "notebooks.googleapis.com" compute.networkUser role granted to notebooks service account for Notebooks on shared VPC Project if no subnets defined
 if "networkconnectivity.googleapis.com" compute.networkUser role granted to notebooks service account for Notebooks on shared VPC Project if no subnets defined
 if "run.googleapis.com" compute.networkUser role granted to Cloud Run service account for Cloud Run on shared VPC Project if no subnets defined
 *****************************************/
resource "google_project_iam_member" "service_shared_vpc_user" {
  for_each = (length(var.shared_vpc_subnets) == 0) && var.enable_shared_vpc_service_project && var.grant_network_role ? toset(local.active_apis) : []
  project  = var.host_project_id
  role     = local.apis[each.value].role
  member   = format("serviceAccount:%s", local.apis[each.value].service_account)
}

/******************************************
  composer.sharedVpcAgent role granted to Composer service account for Composer on shared VPC host project
  See: https://cloud.google.com/composer/docs/how-to/managing/configuring-shared-vpc
 *****************************************/
resource "google_project_iam_member" "composer_host_agent" {
  count   = local.composer_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/composer.sharedVpcAgent"
  member  = format("serviceAccount:%s", local.apis["composer.googleapis.com"].service_account)
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC host project
  See: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count   = local.gke_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = format("serviceAccount:%s", local.apis["container.googleapis.com"].service_account)
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
  member  = format("serviceAccount:%s", local.apis["container.googleapis.com"].service_account)
}

/******************************************
  roles/compute.networkAdmin role granted to Datastream's service account for datastream connectivity configuration on shared VPC host project
  See: https://cloud.google.com/datastream/docs/create-a-private-connectivity-configuration
  Service Account: service-[project_number]@gcp-sa-datastream.iam.gserviceaccount.com
 *****************************************/
resource "google_project_iam_member" "datastream_network_admin" {
  count   = local.datastream_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_services_network_admin_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.networkAdmin"
  member  = format("serviceAccount:%s", local.apis["datastream.googleapis.com"].service_account)
}

/******************************************
  roles/compute.networkViewer role granted to Data Fusion's service account on shared VPC host project
  Service Account: service-[project_number]@gcp-sa-datafusion.iam.gserviceaccount.com
 *****************************************/
resource "google_project_iam_member" "datasfusion_network_viewer" {
  count   = local.datafusion_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.networkViewer"
  member  = format("serviceAccount:%s", local.apis["datafusion.googleapis.com"].service_account)
}

/******************************************
  roles/managedkafka.serviceAgent role granted to Managed Apache Kafka's service account on shared VPC host project
  Service Account: service-[project_number]@gcp-sa-managedkafka.iam.gserviceaccount.com
 *****************************************/
resource "google_project_iam_member" "managed_kafka_service_agent" {
  count   = local.managedkafka_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/managedkafka.serviceAgent"
  member  = format("serviceAccount:service-%s@gcp-sa-managedkafka.iam.gserviceaccount.com", local.service_project_number)
}

/******************************************
  roles/compute.networkViewer role granted to Cloud Run's service account on shared VPC host project if subnets defined
  See: https://cloud.google.com/run/docs/configuring/shared-vpc-direct-vpc#iam
  Service Account: service-[project_number]@serverless-robot-prod.iam.gserviceaccount.com
 *****************************************/
resource "google_project_iam_member" "cloudrun_network_viewer" {
  count   = (length(var.shared_vpc_subnets) > 0) && local.cloudrun_shared_vpc_enabled && var.enable_shared_vpc_service_project && var.grant_network_role ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.networkViewer"
  member  = format("serviceAccount:%s", local.apis["run.googleapis.com"].service_account)
}
