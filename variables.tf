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

variable "random_project_id" {
  description = "Enables project random id generation"
  default     = "false"
}

variable "org_id" {
  description = "The organization id (optional if `domain` is passed)"
  default     = ""
}

variable "domain" {
  description = "The domain name (optional if `org_id` is passed)"
  default     = ""
}

variable "name" {
  description = "The name for the project"
}

variable "shared_vpc" {
  description = "The ID of the host project which hosts the shared VPC"
  default     = ""
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  default     = ""
}

variable "group_name" {
  description = "A group to control the project by being assigned group_role (defaults to project editor)"
  default     = ""
}

variable "create_group" {
  description = "Whether to create the group or not"
  default     = "false"
}

variable "group_role" {
  description = "The role to give the controlling group (group_name) over the project (defaults to project editor)"
  default     = "roles/editor"
}

variable "sa_group" {
  description = "A GSuite group to place the default Service Account for the project in"
  default     = ""
}

variable "sa_role" {
  description = "A role to give the default Service Account for the project (defaults to none)"
  default     = ""
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = "list"
  default     = ["compute.googleapis.com"]
}

variable "usage_bucket_name" {
  description = "Name of a GCS bucket to store GCE usage reports in (optional)"
  default     = ""
}

variable "usage_bucket_prefix" {
  description = "Prefix in the GCS bucket to store GCE usage reports in (optional)"
  default     = ""
}

variable "credentials_path" {
  description = "Path to a Service Account credentials file with permissions documented in the readme"
}

variable "shared_vpc_subnets" {
  description = "List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id)"
  type        = "list"
  default     = [""]
}

variable "labels" {
  description = "Map of labels for project"
  type        = "map"
  default     = {}
}

variable "bucket_project" {
  description = "A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional)"
  default     = ""
}

variable "bucket_name" {
  description = "A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional)"
  default     = ""
}

variable "api_sa_group" {
  description = "A GSuite group to place the Google APIs Service Account for the project in"
  default     = ""
}

variable "auto_create_network" {
  description = "Create the default network"
  default     = "false"
}

variable "app_engine" {
  description = "A map for app engine configuration"
  type        = "map"
  default     = {}
}

variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
  default     = "false"
  type        = "string"
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed"
  default     = "true"
  type        = "string"
}
