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

/******************************************
  Consumer Quota
 *****************************************/

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "quota-project" {
  source            = "../../"
  name              = "pf-ci-test-quota-${random_string.suffix.result}"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "serviceconsumermanagement.googleapis.com"
  ]
  activate_api_identities = [{
    api = "serviceconsumermanagement.googleapis.com"
    roles = [
      "roles/serviceconsumermanagement.tenancyUnitsAdmin"
    ]
  }]

  consumer_quotas = [
    {
      service    = "compute.googleapis.com"
      metric     = "SimulateMaintenanceEventGroup"
      dimensions = {
        region = "us-central1"
      }
      limit      = "%2F100s%2Fproject"
      value      = "19"
      }, {
      service    = "servicemanagement.googleapis.com"
      metric     = "servicemanagement.googleapis.com%2Fdefault_requests"
      dimensions = {}
      limit      = "%2Fmin%2Fproject"
      value      = "95"
    }
  ]
}
