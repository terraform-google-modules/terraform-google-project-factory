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

variable "api_sa_group" {
  description = "A GSuite group to place the Google APIs Service Account for the project in"
  default     = ""
}

variable "create_group" {
  description = "Whether to create the group or not"
  default     = "true"
}

variable "sa_group" {
  description = "A GSuite group to place the default Service Account for the project in"
  default     = ""
}
