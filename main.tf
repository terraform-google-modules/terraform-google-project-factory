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
  source = "modules/gsuite_group"

  domain = "${var.domain}"
  name   = "${var.group_name}"
  org_id = "${var.org_id}"
}

module "project-factory" {
  source = "modules/core_project_factory"

  group_email                 = "${module.gsuite_group.email}"
  group_role                  = "${var.group_role}"
  lien                        = "${var.lien}"
  manage_group                = "${var.group_name != "" ? "true" : "false"}"
  random_project_id           = "${var.random_project_id}"
  org_id                      = "${var.org_id}"
  name                        = "${var.name}"
  shared_vpc                  = "${var.shared_vpc}"
  billing_account             = "${var.billing_account}"
  folder_id                   = "${var.folder_id}"
  sa_role                     = "${var.sa_role}"
  activate_apis               = "${var.activate_apis}"
  usage_bucket_name           = "${var.usage_bucket_name}"
  usage_bucket_prefix         = "${var.usage_bucket_prefix}"
  credentials_path            = "${var.credentials_path}"
  shared_vpc_subnets          = "${var.shared_vpc_subnets}"
  labels                      = "${var.labels}"
  bucket_project              = "${var.bucket_project}"
  bucket_name                 = "${var.bucket_name}"
  auto_create_network         = "${var.auto_create_network}"
  disable_services_on_destroy = "${var.disable_services_on_destroy}"
  app_engine_enabled          = "${var.app_engine_enabled}"
  app_engine_location_id      = "${var.app_engine_location_id}"
  app_engine_auth_domain      = "${var.app_engine_auth_domain}"
  app_engine_serving_status   = "${var.app_engine_serving_status}"
  app_engine_feature_settings = "${var.app_engine_feature_settings}"
}
