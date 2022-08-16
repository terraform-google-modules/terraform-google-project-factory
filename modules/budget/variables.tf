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

variable "billing_account" {
  description = "ID of the billing account to set a budget on"
  type        = string
}

variable "projects" {
  description = "The project ids to include in this budget. If empty budget will include all projects"
  type        = list(string)
}

variable "amount" {
  description = "The amount to use as the budget"
  type        = number
}

variable "create_budget" {
  description = "If the budget should be created"
  type        = bool
  default     = true
}

variable "display_name" {
  description = "The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` "
  type        = string
  default     = null
}

variable "credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  type        = string
  default     = "INCLUDE_ALL_CREDITS"
}

variable "services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/"
  type        = list(string)
  default     = null
}

variable "calendar_period" {
  description = "Specifies the calendar period for the budget. Possible values are MONTH, QUARTER, YEAR, CALENDAR_PERIOD_UNSPECIFIED, CUSTOM. custom_period_start_date and custom_period_end_date must be set if CUSTOM"
  type        = string
  default     = null
}

variable "custom_period_start_date" {
  description = "Specifies the start date (DD-MM-YYYY) for the calendar_period CUSTOM"
  type        = string
  default     = null
}

variable "custom_period_end_date" {
  description = "Specifies the end date (DD-MM-YYYY) for the calendar_period CUSTOM"
  type        = string
  default     = null
}

variable "alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded"
  type        = list(number)
  default     = [0.5, 0.7, 1.0]
}

variable "alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`"
  type        = string
  default     = null
}

variable "monitoring_notification_channels" {
  description = "A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}
