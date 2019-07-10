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
  credentials_file_path = "${path.module}/sa-key.json"
}

/******************************************
  Provider configuration
 *****************************************/
provider "gsuite" {
  credentials = file(local.credentials_file_path)
  version     = "~> 0.1.12"
}

module "app-engine" {
  source           = "../../modules/app_engine"
  location_id      = var.location_id
  auth_domain      = var.auth_domain
  serving_status   = var.serving_status
  feature_settings = [{ enabled = true }]
  project_id       = "example-project"
}
