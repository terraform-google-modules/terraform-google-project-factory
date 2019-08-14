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

variable "org_id" {
}

variable "folder_id" {
  default = ""
}

variable "domain" {
}

variable "usage_bucket_name" {
  default = ""
}

variable "usage_bucket_prefix" {
  default = ""
}

variable "billing_account" {
}

variable "group_name" {
  default = ""
}

variable "create_group" {
  type    = bool
  default = false
}

variable "group_role" {
  default = "roles/viewer"
}

variable "shared_vpc" {
  default = ""
}

variable "sa_role" {
  default = "roles/editor"
}

variable "sa_group" {
  default = ""
}

variable "region" {
  default = "us-east4"
}

variable "gsuite_admin_account" {
}

variable "random_string_for_testing" {
  description = "A random string of characters to be appended to resource names to ensure uniqueness"
}

variable "shared_vpc_enabled" {
  description = "If shared VPC should be used"
  type        = bool
  default     = false
}
