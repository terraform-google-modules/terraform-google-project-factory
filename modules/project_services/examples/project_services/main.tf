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
  credentials_file_path = var.credentials_path
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  credentials = file(local.credentials_file_path)
  version     = "~> 2.1"
}

provider "google-beta" {
  credentials = file(local.credentials_file_path)
  version     = "~> 2.1"
}

module "project-services" {
  source                      = "../../../../modules/project_services"
  project_id                  = var.project_id
  enable_apis                 = "true"
  disable_services_on_destroy = "true"

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

