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

output "extra_service_account_email" {
  value = google_service_account.extra_service_account.email
}

output "shared_vpc_subnet_name_01" {
  value = local.shared_vpc_subnet_name_01
}

output "shared_vpc_subnet_region_01" {
  value = local.shared_vpc_subnet_region_01
}

output "shared_vpc_subnet_name_02" {
  value = local.shared_vpc_subnet_name_02
}

output "shared_vpc_subnet_region_02" {
  value = local.shared_vpc_subnet_region_02
}

output "project_name" {
  value = module.project-factory.project_name
}

output "project_id" {
  value = module.project-factory.project_id
}

output "project_number" {
  value = module.project-factory.project_number
}

output "domain" {
  value = module.project-factory.domain
}

output "group_email" {
  value = module.project-factory.group_email
}

output "group_role" {
  value = var.group_role
}

output "service_account_email" {
  value = module.project-factory.service_account_email
}

output "compute_service_account_email" {
  value = "${module.project-factory.project_number}-compute@developer.gserviceaccount.com"
}

output "gsuite_admin_account" {
  value = var.gsuite_admin_account
}

output "region" {
  value = var.region
}

output "sa_role" {
  value = var.sa_role
}

output "shared_vpc" {
  value = var.shared_vpc
}

output "usage_bucket_name" {
  value = var.usage_bucket_name
}

output "usage_bucket_prefix" {
  value = var.usage_bucket_prefix
}

