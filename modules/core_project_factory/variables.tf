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
  description = "Adds a suffix of 4 random characters to the `project_id`"
  type        = bool
  default     = false
}

variable "org_id" {
  description = "The organization ID."
  type        = string
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

variable "credentials_path" {
  description = "Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials."
  type        = string
  default     = ""
}

variable "impersonate_service_account" {
  description = "An optional service account to impersonate. If this service account is not specified, Terraform will fall back to credential file or Application Default Credentials."
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

variable "shared_vpc_enabled" {
  description = "If shared VPC should be used"
  type        = bool
}

variable "python_interpreter_path" {
  description = "Python interpreter path for precondition check script."
  type        = string
  default     = "python3"
}

variable "pip_executable_path" {
  description = "Pip executable path for precondition requirements.txt install."
  type        = string
  default     = "pip3"
}

variable "use_tf_google_credentials_env_var" {
  description = "Use GOOGLE_CREDENTIALS environment variable to run gcloud auth activate-service-account with."
  type        = bool
  default     = false
}

variable "skip_gcloud_download" {
  description = "Whether to skip downloading gcloud (assumes gcloud is already available outside the module)"
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
