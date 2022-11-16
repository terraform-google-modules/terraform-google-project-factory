/**
 * Copyright 2022 Google LLC
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
  description = "The GCP project you want to send Essential Contacts notifications for"
  type        = string
}

variable "essential_contacts" {
  description = "A mapping of users or groups to be assigned as Essential Contacts to the project, specifying a notification category"
  type        = map(list(string))
  default     = {}
}

variable "language_tag" {
  description = "Language code to be used for essential contacts notifiactions"
  type        = string
}
