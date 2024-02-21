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

output "project_name" {
  description = "Name of the project"
  value       = module.project-factory.project_name
}

output "project_id" {
  description = "ID of the project"
  value       = module.project-factory.project_id
}

output "project_number" {
  description = "Numeric identifier for the project"
  value       = module.project-factory.project_number
}

output "domain" {
  value       = module.gsuite_group.domain
  description = "The organization's domain"
}

output "group_email" {
  value       = module.gsuite_group.email
  description = "The email of the G Suite group with group_name"
}

output "service_account_id" {
  value       = module.project-factory.service_account_id
  description = "The id of the default service account"
}

output "service_account_display_name" {
  value       = module.project-factory.service_account_display_name
  description = "The display name of the default service account"
}

output "service_account_email" {
  value       = module.project-factory.service_account_email
  description = "The email of the default service account"
}

output "service_account_name" {
  value       = module.project-factory.service_account_name
  description = "The fully-qualified name of the default service account"
}

output "service_account_unique_id" {
  value       = module.project-factory.service_account_unique_id
  description = "The unique id of the default service account"
}

output "project_bucket_self_link" {
  value       = module.project-factory.project_bucket_self_link
  description = "Project's bucket selfLink"
}

output "project_bucket_url" {
  value       = module.project-factory.project_bucket_url
  description = "Project's bucket url"
}

output "api_s_account" {
  value       = module.project-factory.api_s_account
  description = "API service account email"
}

output "api_s_account_fmt" {
  value       = module.project-factory.api_s_account_fmt
  description = "API service account email formatted for terraform use"
}

output "enabled_apis" {
  description = "Enabled APIs in the project"
  value       = module.project-factory.enabled_apis
}

output "enabled_api_identities" {
  description = "Enabled API identities in the project"
  value       = module.project-factory.enabled_api_identities
}

output "budget_name" {
  value       = module.budget.name
  description = "The name of the budget if created"
}

output "tag_bindings" {
  description = "Tag bindings"
  value       = module.project-factory.tag_bindings
}
