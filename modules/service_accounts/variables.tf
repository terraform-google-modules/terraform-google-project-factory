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

variable "project_id" {
  type        = "string"
  description = "The ID of the project where service accounts will be created"
}

variable "service_accounts" {
  type        = "list"
  description = "A list of service accounts to create"
}

variable "credentials_path" {
  type        = "string"
  description = "Credentials for managing service accounts"
}

variable "shared_vpc_subnets" {
  type        = "list"
  description = "Shared VPC subnets that service accounts with network access will be able to manage"
  default     = []
}

variable "impersonated_user_email" {
  type = "string"
  default = ""
  description = "The email address to use when managing service account group membership"
}
