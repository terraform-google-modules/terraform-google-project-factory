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

variable "domain" {
  description = "The domain name (optional if `email` is passed)"
  default     = ""
}

variable "email" {
  description = "The email used for the group, this is automatically created"
  default     = ""
}

variable "name" {
  description = <<EOD
  A group to control the project by being assigned group_role - defaults to ${project_name}-editors
  EOD

  default = ""
}

variable "project_name" {
  description = "The name of the project in which the group will exist"
}
