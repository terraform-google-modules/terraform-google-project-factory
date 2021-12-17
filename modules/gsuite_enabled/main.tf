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
  group_name = var.group_name != "" ? var.group_name : format("%s-editors", var.name)
}

/***********************************************
  Make service account member of sa_group group
 ***********************************************/
resource "gsuite_group_member" "service_account_sa_group_member" {
  count = var.sa_group != "" ? 1 : 0

  group = var.sa_group
  email = module.project-factory.service_account_email
  role  = "MEMBER"
}

/*****************************************
  G Suite group information retrieval
 *****************************************/
module "gsuite_group" {
  source = "../gsuite_group"

  domain = var.domain
  name   = local.group_name
  org_id = var.org_id
}

/******************************************
  Gsuite Group Configuration
 *****************************************/
resource "gsuite_group" "group" {
  count = var.create_group ? 1 : 0

  description = "${var.name} project group"
  email       = module.gsuite_group.email
  name        = local.group_name
}

/***********************************************
  Make APIs service account member of api_sa_group
 ***********************************************/
resource "gsuite_group_member" "api_s_account_api_sa_group_member" {
  count = var.api_sa_group != "" ? 1 : 0

  group = var.api_sa_group
  email = module.project-factory.api_s_account
  role  = "MEMBER"
}

module "project-factory" {
  source = "../core_project_factory/"

  group_email = element(
    compact(
      concat(gsuite_group.group.*.email, [module.gsuite_group.email]),
    ),
    0,
  )
  group_role                        = var.group_role
  lien                              = var.lien
  manage_group                      = var.group_name != "" || var.create_group
  random_project_id                 = var.random_project_id
  org_id                            = var.org_id
  name                              = var.name
  project_id                        = var.project_id
  shared_vpc                        = var.shared_vpc
  enable_shared_vpc_service_project = var.enable_shared_vpc_service_project
  enable_shared_vpc_host_project    = var.enable_shared_vpc_host_project
  billing_account                   = var.billing_account
  folder_id                         = var.folder_id
  create_project_sa                 = var.create_project_sa
  project_sa_name                   = var.project_sa_name
  sa_role                           = var.sa_role
  activate_apis                     = var.activate_apis
  usage_bucket_name                 = var.usage_bucket_name
  usage_bucket_prefix               = var.usage_bucket_prefix
  shared_vpc_subnets                = var.shared_vpc_subnets
  labels                            = var.labels
  bucket_project                    = var.bucket_project
  bucket_name                       = var.bucket_name
  bucket_location                   = var.bucket_location
  bucket_versioning                 = var.bucket_versioning
  auto_create_network               = var.auto_create_network
  disable_services_on_destroy       = var.disable_services_on_destroy
  default_service_account           = var.default_service_account
  disable_dependent_services        = var.disable_dependent_services
  default_network_tier              = var.default_network_tier
}

/******************************************
  Billing budget to create if amount is set
 *****************************************/
module "budget" {
  source        = "../budget"
  create_budget = var.budget_amount != null

  projects                         = [module.project-factory.project_id]
  billing_account                  = var.billing_account
  amount                           = var.budget_amount
  alert_spent_percents             = var.budget_alert_spent_percents
  alert_pubsub_topic               = var.budget_alert_pubsub_topic
  monitoring_notification_channels = var.budget_monitoring_notification_channels
}

/******************************************
  Consumer Quota
 *****************************************/
module "project_quota_manager" {
  source          = "../../modules/quota_manager"
  project_id      = module.project-factory.project_id
  consumer_quotas = var.consumer_quotas
}
