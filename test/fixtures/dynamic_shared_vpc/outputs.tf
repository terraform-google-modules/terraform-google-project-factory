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

output "service_project_name" {
  value       = module.example.service_project.project_name
  description = "The service project name"
}

output "service_project_id" {
  value       = module.example.service_project.project_id
  description = "The service project ID"
}

output "service_project_ids" {
  value = [
    module.example.service_project.project_id,
    module.example.service_project_b.project_id,
    module.example.service_project_c.project_id
  ]
  description = "The service project IDs"
}

output "service_project_number" {
  value       = module.example.service_project.project_number
  description = "The service project number"
}

output "service_project_b_number" {
  value       = module.example.service_project_b.project_number
  description = "The service project b number"
}

output "service_project_c_number" {
  value       = module.example.service_project_c.project_number
  description = "The service project c number"
}

output "service_account_email" {
  value       = module.example.service_project.service_account_email
  description = "The service account email"
}

output "secondary_service_account_email" {
  value       = module.example.service_project_b.service_account_email
  description = "The secondary service account email"
}

output "shared_vpc" {
  value       = module.example.host_project.project_id
  description = "The host project ID"
}

output "shared_vpc_subnet_name_01" {
  value       = module.example.vpc.subnets_names[0]
  description = "The first subnet name"
}

output "shared_vpc_subnet_region_01" {
  value       = module.example.vpc.subnets_regions[0]
  description = "The first subnet region"
}

output "shared_vpc_subnet_name_02" {
  value       = module.example.vpc.subnets_names[1]
  description = "The second subnet name"
}

output "shared_vpc_subnet_region_02" {
  value       = module.example.vpc.subnets_regions[1]
  description = "The second subnet region"
}
