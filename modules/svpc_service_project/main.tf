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

/*****************************************
  Organization info retrieval
 *****************************************/
module "gsuite_group" {
  source = "../gsuite_group"

  domain = var.domain
  name   = var.group_name
  org_id = var.org_id
}

module "project-factory" {
  source = "../core_project_factory"

  group_email                       = module.gsuite_group.email
  group_role                        = var.group_role
  lien                              = var.lien
  manage_group                      = var.group_name != "" ? true : false
  random_project_id                 = var.random_project_id
  org_id                            = var.org_id
  name                              = var.name
  project_id                        = var.project_id
  shared_vpc                        = var.shared_vpc
  enable_shared_vpc_service_project = true
  billing_account                   = var.billing_account
  folder_id                         = var.folder_id
  create_project_sa                 = var.create_project_sa
  project_sa_name                   = var.project_sa_name
  sa_role                           = var.sa_role
  activate_apis                     = var.activate_apis
  activate_api_identities           = var.activate_api_identities
  usage_bucket_name                 = var.usage_bucket_name
  usage_bucket_prefix               = var.usage_bucket_prefix
  bucket_versioning                 = var.bucket_versioning
  shared_vpc_subnets                = var.shared_vpc_subnets
  labels                            = var.labels
  bucket_project                    = var.bucket_project
  bucket_name                       = var.bucket_name
  bucket_location                   = var.bucket_location
  auto_create_network               = var.auto_create_network
  disable_services_on_destroy       = var.disable_services_on_destroy
  default_service_account           = var.default_service_account
  disable_dependent_services        = var.disable_dependent_services
}

/******************************************
  Setting API service accounts for shared VPC
 *****************************************/
module "shared_vpc_access" {
  source                             = "../shared_vpc_access"
  host_project_id                    = var.shared_vpc
  enable_shared_vpc_service_project  = true
  service_project_id                 = module.project-factory.project_id
  active_apis                        = module.project-factory.enabled_apis
  shared_vpc_subnets                 = var.shared_vpc_subnets
  service_project_number             = module.project-factory.project_number
  lookup_project_numbers             = false
  grant_services_security_admin_role = var.grant_services_security_admin_role
  grant_services_network_role        = var.grant_services_network_role
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
