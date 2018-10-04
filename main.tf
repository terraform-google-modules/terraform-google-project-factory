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
  args_missing = "${(var.group_name != "" && var.org_id == "" && var.domain == "") ? 1 : 0}"
}

resource "null_resource" "args_missing" {
  count                                                                                           = "${local.args_missing}"
  "ERROR: Variable `group_name` was passed. Please provide either `org_id` or `domain` variables" = true
}

module "project-factory" {
  source              = "modules/core_project_factory"
  random_project_id   = "${var.random_project_id}"
  org_id              = "${var.org_id}"
  domain              = "${var.domain}"
  name                = "${var.name}"
  shared_vpc          = "${var.shared_vpc}"
  billing_account     = "${var.billing_account}"
  folder_id           = "${var.folder_id}"
  group_name          = "${var.group_name}"
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
