/**
 * Copyright 2020 Google LLC
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

output "active_api_service_accounts" {
  description = "List of active API service accounts in the service project."
  value       = local.active_apis
}

output "project_id" {
  description = "Service project ID."
  value       = var.service_project_id
  depends_on = [
    google_compute_subnetwork_iam_member.service_shared_vpc_subnet_users,
    google_project_iam_member.gke_host_agent,
    google_project_iam_member.service_shared_vpc_user,
  ]
}
