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
  Locals configuration
 *****************************************/

locals {
  project_number    = "${module.project-factory.project_number}"
  api_s_account     = "${module.project-factory.api_s_account}"
  api_s_account_fmt = "${module.project-factory.api_s_account_fmt}"
  domain            = "${module.project-factory.domain}"
  args_missing      = "${(var.group_name != "" && var.org_id == "" && var.domain == "") ? 1 : 0}"

  // default group_name to ${project_name}-editors
  group_name        = "${var.group_name != "" ? var.group_name : format("%s-editors", var.name)}"
  given_group_email = "${var.create_group == "false" ? format("%s@%s", var.group_name, local.domain) : ""}"
  final_group_email = "${var.create_group == "true" ? element(coalescelist(gsuite_group.group.*.email, list("")), 0) : local.given_group_email}"
}

resource "null_resource" "args_missing" {
  count                                                                                           = "${local.args_missing}"
  "ERROR: Variable `group_name` was passed. Please provide either `org_id` or `domain` variables" = true
}

/***********************************************
  Make service account member of sa_group group
 ***********************************************/
resource "gsuite_group_member" "service_account_sa_group_member" {
  count = "${var.sa_group != "" ? 1 : 0}"

  group = "${var.sa_group}"
  email = "${module.project-factory.service_account_email}"
  role  = "MEMBER"
}

/******************************************
  Gsuite Group Configuration
 *****************************************/
resource "gsuite_group" "group" {
  count = "${var.create_group ? 1 : 0}"

  email       = "${var.group_name != "" ? format("%s@%s", var.group_name, local.domain) : format("%s-editors@%s", var.name, local.domain)}"
  name        = "${var.group_name != "" ? var.group_name : format("%s-editors",var.name)}"
  description = "${var.name} project group"
}

/***********************************************
  Make APIs service account member of api_sa_group
 ***********************************************/
resource "gsuite_group_member" "api_s_account_api_sa_group_member" {
  count = "${var.api_sa_group != "" ? 1 : 0}"

  group = "${var.api_sa_group}"
  email = "${local.api_s_account}"
  role  = "MEMBER"
}

module "project-factory" {
  source              = "../core_project_factory"
  random_project_id   = "${var.random_project_id}"
  org_id              = "${var.org_id}"
  domain              = "${var.domain}"
  name                = "${var.name}"
  shared_vpc          = "${var.shared_vpc}"
  billing_account     = "${var.billing_account}"
  folder_id           = "${var.folder_id}"
  group_name          = "${var.create_group ? gsuite_group.group.name : local.group_name}"
  group_email         = "${local.final_group_email}"
  group_role          = "${var.group_role}"
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
