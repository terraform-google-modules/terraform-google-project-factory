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

/******************************************
  Project random id suffix configuration
 *****************************************/
resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

/******************************************
  Locals configuration
 *****************************************/
locals {
  group_id               = "${var.manage_group ? format("group:%s", var.group_email) : ""}"
  project_id             = "${google_project.main.project_id}"
  project_number         = "${google_project.main.number}"
  project_org_id         = "${var.folder_id != "" ? "" : var.org_id}"
  project_folder_id      = "${var.folder_id != "" ? var.folder_id : ""}"
  temp_project_id        = "${var.random_project_id ? format("%s-%s",var.name,random_id.random_project_id_suffix.hex) : var.name}"
  s_account_fmt          = "${format("serviceAccount:%s", google_service_account.default_service_account.email)}"
  api_s_account          = "${format("%s@cloudservices.gserviceaccount.com", local.project_number)}"
  api_s_account_fmt      = "${format("serviceAccount:%s", local.api_s_account)}"
  gke_shared_vpc_enabled = "${var.shared_vpc != "" && contains(var.activate_apis, "container.googleapis.com") ? "true" : "false"}"
  gke_s_account          = "${format("service-%s@container-engine-robot.iam.gserviceaccount.com", local.project_number)}"
  gke_s_account_fmt      = "${local.gke_shared_vpc_enabled ? format("serviceAccount:%s", local.gke_s_account) : ""}"
  project_bucket_name    = "${var.bucket_name != "" ? var.bucket_name : format("%s-state", var.name)}"
  create_bucket          = "${var.bucket_project != "" ? "true" : "false"}"

  shared_vpc_users = "${compact(list(local.group_id, local.s_account_fmt, local.api_s_account_fmt, local.gke_s_account_fmt))}"

  # Workaround for https://github.com/hashicorp/terraform/issues/10857
  shared_vpc_users_length = "${local.gke_shared_vpc_enabled ? 4 : 3}"
}

resource "null_resource" "preconditions" {
  triggers {
    credentials_path = "${var.credentials_path}"
    billing_account  = "${var.billing_account}"
    org_id           = "${var.org_id}"
    folder_id        = "${var.folder_id}"
    shared_vpc       = "${var.shared_vpc}"
  }

  provisioner "local-exec" {
    command = <<EOD
${path.module}/scripts/preconditions.sh \
    --credentials_path '${var.credentials_path}' \
    --billing_account '${var.billing_account}' \
    --org_id '${var.org_id}' \
    --folder_id '${var.folder_id}' \
    --shared_vpc '${var.shared_vpc}'
EOD

    environment {
      GRACEFUL_IMPORTERROR = "true"
    }
  }
}

/*******************************************
  Project creation
 *******************************************/
resource "google_project" "main" {
  name                = "${var.name}"
  project_id          = "${local.temp_project_id}"
  org_id              = "${local.project_org_id}"
  folder_id           = "${local.project_folder_id}"
  billing_account     = "${var.billing_account}"
  auto_create_network = "${var.auto_create_network}"

  labels = "${var.labels}"

  depends_on = ["null_resource.preconditions"]
}

/******************************************
  Project lien
 *****************************************/
resource "google_resource_manager_lien" "lien" {
  count        = "${var.lien ? 1 : 0}"
  parent       = "projects/${google_project.main.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "project-factory"
  reason       = "Project Factory lien"
}

/******************************************
  APIs configuration
 *****************************************/
resource "google_project_service" "project_services" {
  count = "${length(var.activate_apis)}"

  project = "${local.project_id}"
  service = "${element(var.activate_apis, count.index)}"

  disable_on_destroy = "${var.disable_services_on_destroy}"

  depends_on = ["google_project.main"]
}

/******************************************
  Shared VPC configuration
 *****************************************/
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  count = "${var.shared_vpc != "" ? 1 : 0}"

  host_project    = "${var.shared_vpc}"
  service_project = "${local.project_id}"

  depends_on = ["google_project_service.project_services"]
}

/******************************************
  Default compute service account retrieval
 *****************************************/
data "null_data_source" "default_service_account" {
  inputs = {
    email = "${google_project.main.number}-compute@developer.gserviceaccount.com"
  }
}

/******************************************
  Default compute service account deletion
 *****************************************/
resource "null_resource" "delete_default_compute_service_account" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/delete-service-account.sh ${local.project_id} ${data.null_data_source.default_service_account.outputs["email"]} ${var.credentials_path}"
  }

  triggers {
    default_service_account = "${data.null_data_source.default_service_account.outputs["email"]}"
    activated_apis          = "${join(",", var.activate_apis)}"
  }

  depends_on = ["google_project_service.project_services"]
}

/******************************************
  Default Service Account configuration
 *****************************************/
resource "google_service_account" "default_service_account" {
  account_id   = "project-service-account"
  display_name = "${var.name} Project Service Account"
  project      = "${local.project_id}"
}

/**************************************************
  Policy to operate instances in shared subnetwork
 *************************************************/
resource "google_project_iam_member" "default_service_account_membership" {
  count   = "${var.sa_role != "" ? 1 : 0}"
  project = "${local.project_id}"
  role    = "${var.sa_role}"

  member = "${local.s_account_fmt}"
}

/******************************************
  Gsuite Group Role Configuration
 *****************************************/
resource "google_project_iam_member" "gsuite_group_role" {
  count = "${var.manage_group ? 1 : 0}"

  member  = "${local.group_id}"
  project = "${local.project_id}"
  role    = "${var.group_role}"
}

/******************************************
  Granting serviceAccountUser to group
 *****************************************/
resource "google_service_account_iam_member" "service_account_grant_to_group" {
  count = "${var.manage_group ? 1 : 0}"

  member = "${local.group_id}"
  role   = "roles/iam.serviceAccountUser"

  service_account_id = "projects/${local.project_id}/serviceAccounts/${
    google_service_account.default_service_account.email
  }"
}

/******************************************************************************************************************
  compute.networkUser role granted to G Suite group, APIs Service account, Project Service Account, and GKE Service
  Account on shared VPC
 *****************************************************************************************************************/
resource "google_project_iam_member" "controlling_group_vpc_membership" {
  count = "${(var.shared_vpc != "" && (length(compact(var.shared_vpc_subnets)) > 0)) ? local.shared_vpc_users_length : 0}"

  project = "${var.shared_vpc}"
  role    = "roles/compute.networkUser"
  member  = "${element(local.shared_vpc_users, count.index)}"

  depends_on = ["google_project_service.project_services"]
}

/*************************************************************************************
  compute.networkUser role granted to Project Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = "google-beta"

  count = "${var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0 }"

  subnetwork = "${element(split("/", var.shared_vpc_subnets[count.index]), 5)}"
  role       = "roles/compute.networkUser"
  region     = "${element(split("/", var.shared_vpc_subnets[count.index]), 3)}"
  project    = "${var.shared_vpc}"
  member     = "${local.s_account_fmt}"
}

/*************************************************************************************
  compute.networkUser role granted to GSuite group on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "group_role_to_vpc_subnets" {
  provider = "google-beta"

  count = "${var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 && var.manage_group ? length(var.shared_vpc_subnets) : 0 }"

  member     = "${local.group_id}"
  project    = "${var.shared_vpc}"
  region     = "${element(split("/", var.shared_vpc_subnets[count.index]), 3)}"
  role       = "roles/compute.networkUser"
  subnetwork = "${element(split("/", var.shared_vpc_subnets[count.index]), 5)}"
}

/*************************************************************************************
  compute.networkUser role granted to APIs Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "apis_service_account_role_to_vpc_subnets" {
  provider = "google-beta"

  count = "${var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 ? length(var.shared_vpc_subnets) : 0 }"

  subnetwork = "${element(split("/", var.shared_vpc_subnets[count.index]), 5)}"
  role       = "roles/compute.networkUser"
  region     = "${element(split("/", var.shared_vpc_subnets[count.index]), 3)}"
  project    = "${var.shared_vpc}"
  member     = "${local.api_s_account_fmt}"

  depends_on = ["google_project_service.project_services"]
}

/***********************************************
  Usage report export (to bucket) configuration
 ***********************************************/
resource "google_project_usage_export_bucket" "usage_report_export" {
  count = "${var.usage_bucket_name != "" ? 1 : 0}"

  project     = "${local.project_id}"
  bucket_name = "${var.usage_bucket_name}"
  prefix      = "${var.usage_bucket_prefix != "" ? var.usage_bucket_prefix : "usage-${local.project_id}"}"

  depends_on = ["google_project_service.project_services"]
}

/***********************************************
  Project's bucket creation
 ***********************************************/
resource "google_storage_bucket" "project_bucket" {
  count = "${local.create_bucket ? 1 : 0}"

  name    = "${local.project_bucket_name}"
  project = "${var.bucket_project}"
}

/***********************************************
  Project's bucket storage.admin granting to group
 ***********************************************/
resource "google_storage_bucket_iam_member" "group_storage_admin_on_project_bucket" {
  count = "${local.create_bucket && var.manage_group ? 1 : 0}"

  bucket = "${google_storage_bucket.project_bucket.name}"
  member = "${local.group_id}"
  role   = "roles/storage.admin"
}

/***********************************************
  Project's bucket storage.admin granting to default compute service account
 ***********************************************/
resource "google_storage_bucket_iam_member" "s_account_storage_admin_on_project_bucket" {
  count = "${local.create_bucket ? 1 : 0}"

  bucket = "${google_storage_bucket.project_bucket.name}"
  role   = "roles/storage.admin"
  member = "${local.s_account_fmt}"
}

/***********************************************
  Project's bucket storage.admin granting to Google APIs service account
 ***********************************************/
resource "google_storage_bucket_iam_member" "api_s_account_storage_admin_on_project_bucket" {
  count = "${local.create_bucket ? 1 : 0}"

  bucket = "${google_storage_bucket.project_bucket.name}"
  role   = "roles/storage.admin"
  member = "${local.api_s_account_fmt}"

  depends_on = ["google_project_service.project_services"]
}

/******************************************
  compute.networkUser role granted to GKE service account for GKE on shared VPC subnets
 *****************************************/
resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
  provider = "google-beta"

  count = "${local.gke_shared_vpc_enabled && length(compact(var.shared_vpc_subnets)) != 0 ? length(var.shared_vpc_subnets) : 0}"

  subnetwork = "${element(split("/", var.shared_vpc_subnets[count.index]), 5)}"
  role       = "roles/compute.networkUser"
  region     = "${element(split("/", var.shared_vpc_subnets[count.index]), 3)}"
  project    = "${var.shared_vpc}"
  member     = "${local.gke_s_account_fmt}"

  depends_on = ["google_project_service.project_services"]
}

/******************************************
  container.hostServiceAgentUser role granted to GKE service account for GKE on shared VPC
 *****************************************/
resource "google_project_iam_member" "gke_host_agent" {
  count = "${local.gke_shared_vpc_enabled ? 1 : 0}"

  project = "${var.shared_vpc}"
  role    = "roles/container.hostServiceAgentUser"
  member  = "${local.gke_s_account_fmt}"

  depends_on = ["google_project_service.project_services"]
}
