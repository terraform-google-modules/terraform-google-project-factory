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
  project_id             = "${google_project.project.project_id}"
  project_number         = "${google_project.project.number}"
  project_org_id         = "${var.folder_id != "" ? "" : var.org_id}"
  project_folder_id      = "${var.folder_id != "" ? var.folder_id : ""}"
  temp_project_id        = "${var.random_project_id ? format("%s-%s",var.name,random_id.random_project_id_suffix.hex) : var.name}"
  domain                 = "${var.domain != "" ? var.domain : var.org_id != "" ? join("", data.google_organization.org.*.domain) : ""}"
  args_missing           = "${var.group_name != "" && var.org_id == "" && var.domain == "" ? 1 : 0}"
  s_account_fmt          = "${format("serviceAccount:%s", google_service_account.default_service_account.email)}"
  api_s_account          = "${format("%s@cloudservices.gserviceaccount.com", local.project_number)}"
  api_s_account_fmt      = "${format("serviceAccount:%s", local.api_s_account)}"
  gke_shared_vpc_enabled = "${var.shared_vpc != "" && contains(var.activate_apis, "container.googleapis.com") ? "true" : "false"}"
  gke_s_account          = "${format("service-%s@container-engine-robot.iam.gserviceaccount.com", local.project_number)}"
  gke_s_account_fmt      = "${local.gke_shared_vpc_enabled ? format("serviceAccount:%s", local.gke_s_account) : ""}"
  project_bucket_name    = "${var.bucket_name != "" ? var.bucket_name : format("%s-state", var.name)}"
  create_bucket          = "${var.bucket_project != "" ? "true" : "false"}"
  gsuite_group           = "${var.group_name != "" || var.create_group}"
  app_engine_enabled     = "${length(keys(var.app_engine)) > 0 ? true : false}"

  shared_vpc_users        = "${compact(list(local.s_account_fmt, data.null_data_source.data_group_email_format.outputs["group_fmt"], local.api_s_account_fmt, local.gke_s_account_fmt))}"
  shared_vpc_users_length = "${local.gke_shared_vpc_enabled ? 4 : 3}"                                                                                                                     # Workaround for https://github.com/hashicorp/terraform/issues/10857

  app_engine_config = {
    enabled  = "${list(var.app_engine)}"
    disabled = "${list()}"
  }
}

resource "null_resource" "args_missing" {
  count                                                                                           = "${local.args_missing}"
  "ERROR: Variable `group_name` was passed. Please provide either `org_id` or `domain` variables" = true
}

/******************************************
  Group email to be used on resources
 *****************************************/
data "null_data_source" "data_final_group_email" {
  inputs {
    final_group_email = "${var.group_name != "" ? format("%s@%s", var.group_name, local.domain) : ""}"
  }
}

/******************************************
  Group email formatting
 *****************************************/
data "null_data_source" "data_group_email_format" {
  inputs {
    group_fmt = "${data.null_data_source.data_final_group_email.outputs["final_group_email"] != "" ? format("group:%s", data.null_data_source.data_final_group_email.outputs["final_group_email"]) : ""}"
  }
}

/******************************************
  Organization info retrieval
 *****************************************/
data "google_organization" "org" {
  count        = "${var.org_id == "" ? 0 : 1}"
  organization = "${var.org_id}"
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
resource "google_project" "project" {
  name                = "${var.name}"
  project_id          = "${local.temp_project_id}"
  org_id              = "${local.project_org_id}"
  folder_id           = "${local.project_folder_id}"
  billing_account     = "${var.billing_account}"
  auto_create_network = "${var.auto_create_network}"

  labels = "${var.labels}"

  app_engine = "${local.app_engine_config["${local.app_engine_enabled ? "enabled" : "disabled"}"]}"

  depends_on = ["null_resource.preconditions"]
}

/******************************************
  Project lien
 *****************************************/
resource "google_resource_manager_lien" "lien" {
  count        = "${var.lien ? 1 : 0}"
  parent       = "projects/${google_project.project.number}"
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "project-factory"
  reason       = "Project Factory lien"
}

/******************************************
  APIs configuration
 *****************************************/
resource "google_project_service" "project_services" {
  count = "${length(var.activate_apis)}"

  project            = "${local.project_id}"
  service            = "${element(var.activate_apis, count.index)}"
  disable_on_destroy = "${var.disable_services_on_destroy}"

  depends_on = ["google_project.project"]
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
data "google_compute_default_service_account" "default" {
  project = "${google_project.project.id}"
}

/******************************************
  Default compute service account deletion
 *****************************************/
resource "null_resource" "delete_default_compute_service_account" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/delete-service-account.sh ${local.project_id} ${var.credentials_path} ${data.google_compute_default_service_account.default.id}"
  }

  triggers {
    default_service_account = "${data.google_compute_default_service_account.default.id}"
    activated_apis          = "${join(",", var.activate_apis)}"
  }

  depends_on = ["google_project_service.project_services", "data.google_compute_default_service_account.default"]
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
  count = "${local.gsuite_group  ? 1 : 0}"

  project = "${local.project_id}"
  role    = "${var.group_role}"
  member  = "${data.null_data_source.data_group_email_format.outputs["group_fmt"]}"
}

/******************************************
  Granting serviceAccountUser to group
 *****************************************/
resource "google_service_account_iam_member" "service_account_grant_to_group" {
  count = "${local.gsuite_group ? 1 : 0}"

  service_account_id = "projects/${local.project_id}/serviceAccounts/${google_service_account.default_service_account.email}"
  role               = "roles/iam.serviceAccountUser"

  member = "${data.null_data_source.data_group_email_format.outputs["group_fmt"]}"
}

/*************************************************************************************
  compute.networkUser role granted to GSuite group, APIs Service account, Project Service Account, and GKE Service Account on shared VPC
 *************************************************************************************/
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
  count = "${var.shared_vpc != "" && length(compact(var.shared_vpc_subnets)) > 0 && local.gsuite_group ? length(var.shared_vpc_subnets) : 0 }"

  subnetwork = "${element(split("/", var.shared_vpc_subnets[count.index]), 5)}"
  role       = "roles/compute.networkUser"
  region     = "${element(split("/", var.shared_vpc_subnets[count.index]), 3)}"
  project    = "${var.shared_vpc}"
  member     = "${data.null_data_source.data_group_email_format.outputs["group_fmt"]}"
}

/*************************************************************************************
  compute.networkUser role granted to APIs Service Account on vpc subnets
 *************************************************************************************/
resource "google_compute_subnetwork_iam_member" "apis_service_account_role_to_vpc_subnets" {
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
  count = "${local.create_bucket && local.gsuite_group ? 1 : 0}"

  bucket = "${google_storage_bucket.project_bucket.name}"
  role   = "roles/storage.admin"
  member = "${data.null_data_source.data_group_email_format.outputs["group_fmt"]}"
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
