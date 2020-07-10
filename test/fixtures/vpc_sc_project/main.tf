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

provider "google" {
  version = "~> 3.8.0"
}

provider "google-beta" {
  version = "~> 3.8.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

module "org_policy" {
  source      = "terraform-google-modules/vpc-service-controls/google/modules/policy"
  parent_id   = var.parent_id
  policy_name = var.policy_name
}

module "regular_service_perimeter_1" {
  source         = "terraform-google-modules/vpc-service-controls/google/modules/regular_service_perimeter"
  policy         = module.org_policy.policy_id
  perimeter_name = "regular_perimeter_1"
  description    = "Some description"
  resources      = ["828469014838"]

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
    "container.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]

  default_service_account            = "disable"
  disable_services_on_destroy        = "false"
  vpc_service_control_perimeter_name = "accessPolicies/${module.org_policy.policy_id}/servicePerimeters/${module.regular_service_parameter_1.perimeter_name}"
}

// Add a binding to the container service robot account to test that the
// dependency on that service is correctly sequenced.
resource "google_project_iam_member" "iam-binding" {
  project = module.project-factory.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:service-${module.project-factory.project_number}@container-engine-robot.iam.gserviceaccount.com"
}
