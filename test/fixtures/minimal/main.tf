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
  version     = "~> 1.19"
}

provider "google-beta" {
  version     = "~> 1.19"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

module "project-factory" {
  source = "../../../"

  name              = "pf-ci-test-minimal-${random_string.suffix.result}"
  random_project_id = true
  domain            = "${var.domain}"
  org_id            = "${var.org_id}"
  folder_id         = "${var.folder_id}"
  billing_account   = "${var.billing_account}"

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]

  disable_services_on_destroy = "false"
}
