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

variable "manage_group" {
  description = "A toggle to indicate if a G Suite group should be managed."
  type        = bool
  default     = false
}

variable "service_project" {
  description = "The project id of the service project"
  type        = string
}

variable "host_project" {
  description = "The ID of the host project which hosts the shared VPC"
  type        = string
  default     = ""
}

variable "shared_vpc_subnets" {
  description = "List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id)"
  type        = list(string)
  default     = [""]
}

variable "shared_vpc_enabled" {
  description = "If shared VPC should be used"
  type        = bool
}

variable "gke_shared_vpc_enabled" {
  description = "If shared VPC should be available to kubernetes"
  type        = bool
  default     = false
}

variable "group_id" {
  type = string
}

variable "s_account_fmt" {
  type = string
}

variable "api_s_account_fmt" {
  type = string
}

variable "gke_s_account_fmt" {
  type = string
}

