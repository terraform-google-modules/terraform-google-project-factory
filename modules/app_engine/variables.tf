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

variable "project_id" {
  description = "The project to enable app engine on."
}

variable "location_id" {
  description = "The location to serve the app from."
  default     = ""
}

variable "auth_domain" {
  description = "The domain to authenticate users with when using App Engine's User API."
  default     = ""
}

variable "serving_status" {
  description = "The serving status of the app."
  default     = "SERVING"
}

variable "feature_settings" {
  description = "A list of maps of optional settings to configure specific App Engine features."
  default     = []
}

