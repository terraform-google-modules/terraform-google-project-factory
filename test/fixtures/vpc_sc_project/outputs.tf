/**
 * Copyright 2019 Google LLC
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
  value = module.project-factory.project_name
}

output "project_id" {
  value = module.project-factory.project_id
}

output "project_number" {
  value = module.project-factory.project_number
}

output "perimeter_name" {
  value = local.perimeter_name
}

output "policy_id" {
  value = var.policy_id
}

output "service_account_email" {
  value       = module.project-factory.service_account_email
  description = "The email of the default service account"
}

output "compute_service_account_email" {
  value       = "${module.project-factory.project_number}-compute@developer.gserviceaccount.com"
  description = "The email of the default compute engine service account"
}

output "container_service_account_email" {
  value       = "service-${module.project-factory.project_number}@container-engine-robot.iam.gserviceaccount.com"
  description = "The email of the default gke service account"
}

output "group_email" {
  value       = module.project-factory.group_email
  description = "The email of the G Suite group with group_name"
}
