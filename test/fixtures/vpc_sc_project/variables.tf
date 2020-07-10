/**
 * Copyright 2019 Google LLC
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

variable "parent_id" {
  type        = string
  description = "The parent of this AccessPolicy in the Cloud Resource Hierarchy. As of now, only organizations are accepted as parent."
  default     = "11111111"
}

variable "policy_name" {
  type        = string
  description = "The policy's name"
  default     = "policy1"
}

variable "org_id" {
  type        = string
  description = "The organization ID"
}

variable "folder_id" {
  type        = string
  description = "The ID of a folder to host this project"
}

variable "billing_account" {
  type        = string
  description = "Billing account ID."
}

variable "random_string_for_testing" {
  type        = string
  description = "A random string of characters to be appended to resource names to ensure uniqueness"
}

variable "vpc_service_control_perimeter_name" {
  type        = string
  description = "The name of an existing VPC Service Control Perimeter to add the created project to"
  default     = null
}
