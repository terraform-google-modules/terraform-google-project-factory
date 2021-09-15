/**
 * Copyright 2021 Google LLC
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
  description = "The GCP project you want to enable APIs on"
  value       = element(concat([for v in google_project_service.project_services : v.project], [var.project_id]), 0)
}

output "essential_contacts" {
  description = "Essential contacts"
  value       = { for i in google_project_service_identity.project_service_identities : i.service => i.email }
}
