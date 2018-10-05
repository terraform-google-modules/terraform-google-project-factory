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

output "project_id" {
  value = "${local.project_id}"
}

output "project_number" {
  value = "${local.project_number}"
}

output "domain" {
  value       = "${local.domain}"
  description = "The organization's domain"
}

output "group_email" {
  value       = "${local.gsuite_group ? data.null_data_source.data_final_group_email.outputs["final_group_email"] : ""}"
  description = "The email of the created GSuite group with group_name"
}

output "project_bucket_self_link" {
  value       = "${google_storage_bucket.project_bucket.*.self_link}"
  description = "Project's bucket selfLink"
}

output "project_bucket_url" {
  value       = "${google_storage_bucket.project_bucket.*.url}"
  description = "Project's bucket url"
}

output "app_engine_enabled" {
  value       = "${local.app_engine_enabled}"
  description = "Whether app engine is enabled"
}
