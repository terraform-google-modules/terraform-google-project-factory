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

module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "pf-ci-test-ec-${var.random_string_for_testing}"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "essentialcontacts.googleapis.com",
    "serviceusage.googleapis.com"
  ]

  essential_contacts = {
    "user1@foo.com"    = ["ALL"],
    "security@foo.com" = ["SECURITY", "TECHNICAL"],
    "app@foo.com"      = ["TECHNICAL"]
  }

  language_tag = "en-US"

  default_service_account     = "DISABLE"
  disable_services_on_destroy = false
}
