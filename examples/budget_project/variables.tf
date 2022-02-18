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

variable "org_id" {
  description = "The organization ID."
  type        = string
}

variable "folder_id" {
  description = "The ID of a folder to host this project."
  type        = string
  default     = ""
}

variable "parent_project_id" {
  description = "The project_id of the parent project to add as an additional project for the budget"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "budget_amount" {
  description = "The amount to use for the budget"
  default     = 10
  type        = number
}

variable "budget_alert_spent_percents" {
  description = "The list of percentages of the budget to alert on"
  type        = list(number)
  default     = [0.7, 0.8, 0.9, 1.0]
}

variable "budget_services" {
  description = "A list of services to be included in the budget"
  type        = list(string)
  default = [
    "6F81-5844-456A", # Compute Engine
    "A1E8-BE35-7EBC"  # Pub/Sub
  ]
}

variable "budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  type        = string
  default     = "EXCLUDE_ALL_CREDITS"
}
