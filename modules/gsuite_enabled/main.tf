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

module "google_group" {
  source = "../google_group"

  domain       = "${module.google_organization.domain}"
  name         = "${var.group_name}"
  project_name = "${var.name}"
}

/***********************************************
  Make service account member of sa_group group
 ***********************************************/
resource "gsuite_group_member" "service_account_sa_group_member" {
  count = "${var.sa_group != "" ? 1 : 0}"

  group = "${var.sa_group}"
  email = "${module.project-factory.service_account_email}"
  role  = "MEMBER"

  depends_on = ["module.project-factory"]
}

/*****************************************
  Organization info retrieval
 *****************************************/
module "google_organization" {
  source = "../google_organization"

  domain = "${var.domain}"
  org_id = "${var.org_id}"
}

/******************************************
  Gsuite Group Configuration
 *****************************************/
resource "gsuite_group" "group" {
  count = "${var.create_group ? 1 : 0}"

  description = "${var.name} project group"
  email       = "${module.google_group.email}"
  name        = "${module.google_group.name}"
}

/***********************************************
  Make APIs service account member of api_sa_group
 ***********************************************/
resource "gsuite_group_member" "api_s_account_api_sa_group_member" {
  count = "${var.api_sa_group != "" ? 1 : 0}"

  group = "${var.api_sa_group}"
  email = "${module.project-factory.api_s_account}"
  role  = "MEMBER"
}

module "project-factory" {
  source = "../core_project_factory/"

  lien                = "${var.lien}"
  random_project_id   = "${var.random_project_id}"
  org_id              = "${var.org_id}"
  domain              = "${var.domain}"
  name                = "${var.name}"
  shared_vpc          = "${var.shared_vpc}"
  billing_account     = "${var.billing_account}"
  folder_id           = "${var.folder_id}"
  group_name          = "${module.google_group.name}"
  group_email         = "${module.google_group.email}"
  sa_role             = "${var.sa_role}"
  activate_apis       = "${var.activate_apis}"
  usage_bucket_name   = "${var.usage_bucket_name}"
  usage_bucket_prefix = "${var.usage_bucket_prefix}"
  credentials_path    = "${var.credentials_path}"
  shared_vpc_subnets  = "${var.shared_vpc_subnets}"
  labels              = "${var.labels}"
  bucket_project      = "${var.bucket_project}"
  bucket_name         = "${var.bucket_name}"
  auto_create_network = "${var.auto_create_network}"
  app_engine          = "${var.app_engine}"
}

/******************************************
  Gsuite Group Role Configuration
 *****************************************/
resource "google_project_iam_member" "gsuite_group_role" {
  member  = "${module.google_group.id}"
  project = "${module.project-factory.project_id}"
  role    = "${var.group_role}"
}

/******************************************
  Granting serviceAccountUser to group
 *****************************************/
resource "google_service_account_iam_member" "service_account_grant_to_group" {
  member = "${module.google_group.id}"
  role   = "roles/iam.serviceAccountUser"

  service_account_id = <<EOS
  projects/${module.project-factory.project_id}/serviceAccounts/${module.project-factory.service_account_email}
  EOS
}

/*************************************************************************************
  compute.networkUser role granted to GSuite group on shared VPC
 *************************************************************************************/
resource "google_project_iam_member" "controlling_group_vpc_membership" {
  count = "${(var.shared_vpc != "" && (length(compact(var.shared_vpc_subnets)) > 0)) ? 1 : 0}"

  member  = "${module.google_group.id}"
  project = "${var.shared_vpc}"
  role    = "roles/compute.networkUser"
}
