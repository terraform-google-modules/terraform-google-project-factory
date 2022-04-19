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

output "project_id" {
  value = module.pfactory_project.project_id
}

output "shared_vpc" {
  value = module.pfactory_project.project_id
}

output "sa_key" {
  value     = google_service_account_key.int_test.private_key
  sensitive = true
}

output "folder_id" {
  value = google_folder.ci_pfactory_folder.folder_id
}

output "org_id" {
  value = var.org_id
}

output "billing_account" {
  value = var.billing_account
}

output "random_string_for_testing" {
  value = random_id.random_string_for_testing.hex
}

output "gsuite_admin_account" {
  value = var.gsuite_admin_email
}

output "domain" {
  value = var.gsuite_domain
}

output "group_name" {
  value = "ci-pfactory-test-group-${random_id.folder_rand.hex}"
}

output "service_account_email" {
  value = google_service_account.int_test.email
}
