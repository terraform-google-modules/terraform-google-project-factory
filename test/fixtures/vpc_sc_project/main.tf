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
  perimeter_name = "regular_service_perimeter_${var.random_string_for_testing}"
}

module "regular_service_perimeter_1" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version        = "~> 5.0"
  policy         = var.policy_id
  perimeter_name = local.perimeter_name
  description    = "New service perimeter"
  resources      = []

  restricted_services = ["storage.googleapis.com"]
}

module "project-factory" {
  source = "../../../"

  name              = "test-vpc-sc-proj-${var.random_string_for_testing}"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "compute.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "storage-component.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  default_service_account     = "DISABLE"
  disable_services_on_destroy = false

  vpc_service_control_attach_enabled = true
  vpc_service_control_perimeter_name = "accessPolicies/${var.policy_id}/servicePerimeters/${local.perimeter_name}"
}

resource "google_project_iam_member" "iam-binding" {
  project = module.project-factory.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${module.project-factory.service_account_email}"
}
