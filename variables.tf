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

variable "domain" {
  description = "The domain name (optional)."
  type        = string
  default     = ""
}

variable "name" {
  description = "The name for the project"
  type        = string
}

variable "project_id" {
  description = "The ID to give the project. If not provided, the `name` will be used."
  type        = string
  default     = ""
}

variable "svpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC"
  type        = string
  default     = ""
}

variable "enable_shared_vpc_host_project" {
  description = "If this project is a shared VPC host project. If true, you must *not* set svpc_host_project_id variable. Default is false."
  type        = bool
  default     = false
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

variable "group_name" {
  description = "A group to control the project by being assigned group_role (defaults to project editor)"
  type        = string
  default     = ""
}

variable "group_role" {
  description = "The role to give the controlling group (group_name) over the project (defaults to project editor)"
  type        = string
  default     = "roles/editor"
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

variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
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

variable "budget_amount" {
  description = "The amount to use for a budget alert"
  type        = number
  default     = null
}

variable "budget_display_name" {
  description = "The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` "
  type        = string
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

variable "budget_alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "budget_labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.budget_labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}

variable "budget_calendar_period" {
  description = "Specifies the calendar period for the budget. Possible values are MONTH, QUARTER, YEAR, CALENDAR_PERIOD_UNSPECIFIED, CUSTOM. custom_period_start_date and custom_period_end_date must be set if CUSTOM"
  type        = string
  default     = null
}

variable "budget_custom_period_start_date" {
  description = "Specifies the start date (DD-MM-YYYY) for the calendar_period CUSTOM"
  type        = string
  default     = null
}

variable "budget_custom_period_end_date" {
  description = "Specifies the end date (DD-MM-YYYY) for the calendar_period CUSTOM"
  type        = string
  default     = null
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

variable "grant_services_security_admin_role" {
  description = "Whether or not to grant Kubernetes Engine Service Agent the Security Admin role on the host project so it can manage firewall rules"
  type        = bool
  default     = false
}

variable "grant_network_role" {
  description = "Whether or not to grant networkUser role on the host project/subnets"
  type        = bool
  default     = true
}

variable "consumer_quotas" {
  description = "The quotas configuration you want to override for the project."
  type = list(object({
    service    = string,
    metric     = string,
    dimensions = map(string),
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

variable "essential_contacts" {
  description = "A mapping of users or groups to be assigned as Essential Contacts to the project, specifying a notification category"
  type        = map(list(string))
  default     = {}
}

variable "language_tag" {
  description = "Language code to be used for essential contacts notifications"
  type        = string
  default     = "en-US"
}

variable "tag_binding_values" {
  description = "Tag values to bind the project to."
  type        = list(string)
  default     = []
}
