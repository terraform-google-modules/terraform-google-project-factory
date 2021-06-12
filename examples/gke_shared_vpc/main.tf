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

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

module "project-factory" {
  source               = "../../"
  random_project_id    = true
  name                 = "sample-gke-shared-project"
  org_id               = var.org_id
  billing_account      = var.billing_account
  svpc_host_project_id = var.shared_vpc
  activate_apis        = ["compute.googleapis.com", "container.googleapis.com", "cloudbilling.googleapis.com"]
  shared_vpc_subnets   = var.shared_vpc_subnets
}
