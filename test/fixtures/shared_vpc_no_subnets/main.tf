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
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.30"
}

provider "gsuite" {
  impersonated_user_email = var.gsuite_admin_account

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]

  version = "~> 0.1.12"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

module "project-factory" {
  source = "../../../modules/gsuite_enabled"

  name                              = "pf-ci-test-nosubnets-${var.random_string_for_testing}"
  project_id                        = "pf-ci-test-nosubnets-${var.random_string_for_testing}"
  random_project_id                 = false
  domain                            = var.domain
  org_id                            = var.org_id
  folder_id                         = var.folder_id
  billing_account                   = var.billing_account
  create_group                      = true
  group_role                        = var.group_role
  group_name                        = "pf-secondgroup-${var.random_string_for_testing}"
  shared_vpc                        = var.shared_vpc
  enable_shared_vpc_service_project = true

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataflow.googleapis.com",
  ]

  disable_services_on_destroy = false
}
