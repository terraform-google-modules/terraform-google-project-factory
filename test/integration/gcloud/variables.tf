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

variable "credentials_path" {}

variable "name" {}

variable "random_project_id" {}

variable "org_id" {
  default = ""
}

variable "folder_id" {
  default = ""
}

variable "domain" {
  default = ""
}

variable "usage_bucket_name" {
  default = ""
}

variable "usage_bucket_prefix" {
  default = ""
}

variable "billing_account" {}

variable "group_name" {
  default = ""
}

variable "create_group" {
  default = ""
}

variable "group_role" {
  default = ""
}

variable "shared_vpc" {
  default = ""
}

variable "sa_role" {
  default = ""
}

variable "sa_group" {
  default = ""
}

variable "activate_apis" {
  type = "list"
}

variable "region" {}

variable "gsuite_admin_account" {}
