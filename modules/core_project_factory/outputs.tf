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

output "service_account_id" {
  value       = "${google_service_account.default_service_account.account_id}"
  description = "The id of the default service account"
}

output "service_account_display_name" {
  value       = "${google_service_account.default_service_account.display_name}"
  description = "The display name of the default service account"
}

output "service_account_email" {
  value       = "${google_service_account.default_service_account.email}"
  description = "The email of the default service account"
}

output "service_account_name" {
  value       = "${google_service_account.default_service_account.name}"
  description = "The fully-qualified name of the default service account"
}

output "service_account_unique_id" {
  value       = "${google_service_account.default_service_account.unique_id}"
  description = "The unique id of the default service account"
}

output "project_bucket_name" {
  description = "The name of the projec's bucket"
  value       = "${google_storage_bucket.project_bucket.*.name}"
}

output "project_bucket_self_link" {
  value       = "${google_storage_bucket.project_bucket.*.self_link}"
  description = "Project's bucket selfLink"
}

output "project_bucket_url" {
  value       = "${google_storage_bucket.project_bucket.*.url}"
  description = "Project's bucket url"
}

output "api_s_account" {
  value       = "${local.api_s_account}"
  description = "API service account email"
}

output "api_s_account_fmt" {
  value       = "${local.api_s_account_fmt}"
  description = "API service account email formatted for terraform use"
}

output "app_engine_name" {
  description = "Unique name of the app, usually apps/{PROJECT_ID}."
  value = "${module.app-engine.name}"
}

output "app_engine_url_dispatch_rule" {
  description = "A list of dispatch rule blocks. Each block has a domain, path, and service field."
  value = "${module.app-engine.url_dispatch_rule}"
}

output "app_engine_code_bucket" {
  description = "The GCS bucket code is being stored in for this app."
  value = "${module.app-engine.code_bucket}"
}

output "app_engine_default_hostname" {
  description = "The default hostname for this app."
  value = "${module.app-engine.default_hostname}"
}

output "app_engine_default_bucket" {
  description = "The GCS bucket content is being stored in for this app."
  value = "${module.app-engine.default_bucket}"
}

output "app_engine_gcr_domain" {
  description = "The GCR domain used for storing managed Docker images for this app."
  value = "${module.app-engine.gcr_domain}"
}
