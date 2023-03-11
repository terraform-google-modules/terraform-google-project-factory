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

variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
  default     = false
  type        = bool
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

variable "domain" {
  description = "The domain name (optional)."
  default     = ""
  type        = string
}

variable "name" {
  description = "The name for the project"
  type        = string
}

variable "project_id" {
  description = "The ID to give the project. If not provided, the `name` will be used."
  default     = ""
  type        = string
}

variable "shared_vpc" {
  description = "The ID of the host project which hosts the shared VPC"
  default     = ""
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  default     = ""
  type        = string
}

variable "group_name" {
  description = "A group to control the project by being assigned group_role - defaults to $${project_name}-editors"
  default     = ""
  type        = string
}

variable "create_group" {
  type        = bool
  description = "Whether to create the group or not"
  default     = false
}

variable "group_role" {
  description = "The role to give the controlling group (group_name) over the project (defaults to project editor)"
  default     = "roles/editor"
  type        = string
}

variable "sa_group" {
  description = "A G Suite group to place the default Service Account for the project in"
  default     = ""
  type        = string
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
  default     = ""
  type        = string
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
  default     = ["compute.googleapis.com"]
}

variable "usage_bucket_name" {
  description = "Name of a GCS bucket to store GCE usage reports in (optional)"
  default     = ""
  type        = string
}

variable "usage_bucket_prefix" {
  description = "Prefix in the GCS bucket to store GCE usage reports in (optional)"
  default     = ""
  type        = string
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
  default     = ""
  type        = string
}

variable "bucket_name" {
  description = "A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional)"
  default     = ""
  type        = string
}

variable "bucket_location" {
  description = "The location for a GCS bucket to create (optional)"
  default     = ""
  type        = string
}

variable "bucket_versioning" {
  description = "Enable versioning for a GCS bucket to create (optional)"
  type        = bool
  default     = false
}

variable "api_sa_group" {
  description = "A G Suite group to place the Google APIs Service Account for the project in"
  default     = ""
  type        = string
}

variable "auto_create_network" {
  description = "Create the default network"
  type        = bool
  default     = false
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed"
  type        = bool
  default     = true
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
  description = "If shared VPC should be used"
  type        = bool
  default     = false
}

variable "enable_shared_vpc_host_project" {
  description = "If this project is a shared VPC host project. If true, you must *not* set shared_vpc variable. Default is false."
  type        = bool
  default     = false
}

variable "budget_amount" {
  description = "The amount to use for a budget alert"
  type        = number
  default     = null
}

variable "budget_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`"
  type        = string
  default     = null
}

variable "budget_monitoring_notification_channels" {
  description = "A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed."
  type        = list(string)
  default     = []
}

variable "budget_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded"
  type        = list(number)
  default     = [0.5, 0.7, 1.0]
}

variable "consumer_quotas" {
  description = "The quotas configuration you want to override for the project."
  type = list(object({
    service    = string,
    metric     = string,
    dimensions = any,
    limit      = string,
    value      = string,
  }))
  default = []
}

variable "default_network_tier" {
  description = "Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers."
  type        = string
  default     = ""
}
