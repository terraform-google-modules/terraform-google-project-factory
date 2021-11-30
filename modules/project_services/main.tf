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

locals {
  activate_compute_identity = 0 != length([for i in var.activate_api_identities : i if i.api == "compute.googleapis.com"])
  services                  = var.enable_apis ? toset(concat(var.activate_apis, [for i in var.activate_api_identities : i.api])) : toset([])
  service_identities = flatten([
    for i in var.activate_api_identities : [
      for r in i.roles :
      { api = i.api, role = r }
    ]
  ])
}

/******************************************
  APIs configuration
 *****************************************/
resource "google_project_service" "project_services" {
  for_each                   = local.services
  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services
}

# First handle all service identities EXCEPT compute.googleapis.com.
resource "google_project_service_identity" "project_service_identities" {
  for_each = {
    for i in var.activate_api_identities :
    i.api => i
    if i.api != "compute.googleapis.com"
  }

  provider = google-beta
  project  = var.project_id
  service  = each.value.api
}

# Process the compute.googleapis.com identity separately, if present in the inputs.
data "google_compute_default_service_account" "default" {
  count   = local.activate_compute_identity ? 1 : 0
  project = var.project_id
}

locals {
  add_service_roles = merge(
    {
      for si in local.service_identities :
      "${si.api} ${si.role}" => {
        email = google_project_service_identity.project_service_identities[si.api].email
        role  = si.role
      }
      if si.api != "compute.googleapis.com"
    },
    {
      for si in local.service_identities :
      "${si.api} ${si.role}" => {
        email = data.google_compute_default_service_account.default[0].email
        role  = si.role
      }
      if si.api == "compute.googleapis.com"
    }
  )
}

resource "google_project_iam_member" "project_service_identity_roles" {
  for_each = local.add_service_roles

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"
}
