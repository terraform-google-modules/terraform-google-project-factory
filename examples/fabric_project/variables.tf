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

variable "activate_apis" {
  description = "Service APIs to enable."
  type        = list(string)
  default     = ["serviceusage.googleapis.com", "compute.googleapis.com"]
}

variable "billing_account" {
  description = "Billing account id."
  type        = string
}

variable "name" {
  description = "Project name, joined with prefix."
  type        = string
  default     = "fabric-project"
}

variable "owners" {
  description = "Optional list of IAM-format members to set as project owners."
  type        = list(string)
  default     = []
}

variable "parent" {
  description = "Organization or folder id, in the `organizations/nnn` or `folders/nnn` format."
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to project name, uses random id by default."
  type        = string
  default     = ""
}
