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

variable "admin_email" {
  description = "Admin user email on Gsuite"
  default     = "casey@phoogle.net"
}

variable "credentials_file_path" {
  description = "Service account json auth path"
  default     = "~/testing/serviceAccountKeys/orgserviceaccount.json"
}

variable "organization_id" {
  description = "The organization id for the associated services"
  default     = "826592752744"
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  default     = "01E8A0-35F760-5CF02A"
}

variable "api_sa_group" {
  description = "An existing GSuite group email to place the Google APIs Service Account for the project in"
  default     = "api_sa_group@phoogle.net"
}

variable "project_group_name" {
  description = "The name of a GSuite group to create for controlling the project"
  default     = "cpearring-test"
}