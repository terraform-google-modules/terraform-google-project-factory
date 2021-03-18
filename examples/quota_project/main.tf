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
  version = "~> 3.54"
}

provider "google-beta" {
  version = "~> 3.54"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

/******************************************
  Consumer Quota
 *****************************************/
module "project_quota_manager" {
  source = "../../modules/quota_manager"

  project_id = var.project_id
  consumer_quotas = [
    {
      service = "compute.googleapis.com"
      metric  = "SimulateMaintenanceEventGroup"
      limit   = "%2F100s%2Fproject"
      value   = "19"
      }, {
      service = "servicemanagement.googleapis.com"
      metric  = "servicemanagement.googleapis.com%2Fdefault_requests"
      limit   = "%2Fmin%2Fproject"
      value   = "95"
    }
  ]
}
