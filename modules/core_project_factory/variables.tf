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

variable "group_email" {
  description = "The email address of a group to control the project by being assigned group_role."
  type        = string
  default     = ""
}

variable "group_role" {
  description = "The role to give the controlling group (group_name) over the project."
  type        = string
  default     = ""
}

variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
  default     = false
  type        = bool
}

variable "manage_group" {
  description = "A toggle to indicate if a G Suite group should be managed."
  type        = bool
  default     = false
}

variable "project_id" {
  description = "The ID to give the project. If not provided, the `name` will be used."
  type        = string
  default     = ""
}

variable "random_project_id" {
  description = "Adds a suffix of 4 random characters to the `project_id`."
  type        = bool
  default     = false
}

variable "random_project_id_length" {
  description = "Sets the length of `random_project_id` to the provided length, and uses a `random_string` for a larger collusion domain.  Recommended for use with CI."
  type        = number
  default     = null
}

variable "org_id" {
  description = "The organization ID."
  type        = string
  default     = null
}

variable "name" {
  description = "The name for the project"
  type        = string
}

variable "shared_vpc" {
  description = "The ID of the host project which hosts the shared VPC"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}

variable "create_project_sa" {
  description = "Whether the default service account for the project shall be created"
  type        = bool
  default     = true
}

variable "project_sa_name" {
  description = "Default service account name for the project."
  type        = string
  default     = "project-service-account"
}

variable "sa_role" {
  description = "A role to give the default Service Account for the project (defaults to none)"
  type        = string
  default     = ""
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
  default     = ["compute.googleapis.com"]
}

variable "activate_api_identities" {
  description = <<EOF
    The list of service identities (Google Managed service account for the API) to force-create for the project (e.g. in order to grant additional roles).
    APIs in this list will automatically be appended to `activate_apis`.
    Not including the API in this list will follow the default behaviour for identity creation (which is usually when the first resource using the API is created).
    Any roles (e.g. service agent role) must be explicitly listed. See https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles for a list of related roles.
  EOF
  type = list(object({
    api   = string
    roles = list(string)
  }))
  default = []
}

variable "usage_bucket_name" {
  description = "Name of a GCS bucket to store GCE usage reports in (optional)"
  type        = string
  default     = ""
}

variable "usage_bucket_prefix" {
  description = "Prefix in the GCS bucket to store GCE usage reports in (optional)"
  type        = string
  default     = ""
}

variable "shared_vpc_subnets" {
  description = "List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id)"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Map of labels for project"
  type        = map(string)
  default     = {}
}

variable "bucket_project" {
  description = "A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional)"
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional)"
  type        = string
  default     = ""
}

variable "bucket_location" {
  description = "The location for a GCS bucket to create (optional)"
  type        = string
  default     = "US"
}

variable "bucket_versioning" {
  description = "Enable versioning for a GCS bucket to create (optional)"
  type        = bool
  default     = false
}

variable "bucket_labels" {
  description = " A map of key/value label pairs to assign to the bucket (optional)"
  type        = map(string)
  default     = {}
}

variable "bucket_force_destroy" {
  description = "Force the deletion of all objects within the GCS bucket when deleting the bucket (optional)"
  type        = bool
  default     = false
}

variable "bucket_ula" {
  description = "Enable Uniform Bucket Level Access"
  type        = bool
  default     = true
}

variable "bucket_pap" {
  description = "Enable Public Access Prevention. Possible values are \"enforced\" or \"inherited\"."
  type        = string
  default     = "inherited"
}

variable "auto_create_network" {
  description = "Create the default network"
  type        = bool
  default     = false
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed"
  default     = true
  type        = bool
}

variable "default_service_account" {
  description = "Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`."
  default     = "disable"
  type        = string
}

variable "disable_dependent_services" {
  description = "Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed."
  default     = true
  type        = bool
}

variable "enable_shared_vpc_service_project" {
  description = "If this project should be attached to a shared VPC. If true, you must set shared_vpc variable."
  type        = bool
}

variable "enable_shared_vpc_host_project" {
  description = "If this project is a shared VPC host project. If true, you must *not* set shared_vpc variable. Default is false."
  type        = bool
  default     = false
}

variable "vpc_service_control_attach_enabled" {
  description = "Whether the project will be attached to a VPC Service Control Perimeter"
  type        = bool
  default     = false
}

variable "vpc_service_control_perimeter_name" {
  description = "The name of a VPC Service Control Perimeter to add the created project to"
  type        = string
  default     = null
}

variable "vpc_service_control_sleep_duration" {
  description = "The duration to sleep in seconds before adding the project to a shared VPC after the project is added to the VPC Service Control Perimeter. VPC-SC is eventually consistent."
  type        = string
  default     = "5s"
}

variable "default_network_tier" {
  description = "Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers."
  type        = string
  default     = ""
}

variable "grant_network_role" {
  description = "Whether or not to grant networkUser role on the host project/subnets"
  type        = bool
  default     = true
}

variable "tag_binding_values" {
  description = "Tag values to bind the project to."
  type        = list(string)
  default     = []
}
