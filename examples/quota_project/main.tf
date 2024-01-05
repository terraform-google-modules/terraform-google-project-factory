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
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name              = "pf-ci-test-quota-${random_string.suffix.result}"
  random_project_id = true
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "servicemanagement.googleapis.com"
  ]

  consumer_quotas = [
    {
      service = "compute.googleapis.com"
      metric  = urlencode("compute.googleapis.com/n2_cpus")
      limit   = urlencode("/project/region")
      dimensions = {
        region = "us-central1"
      }
      value = "10"
    },
    {
      service    = "servicemanagement.googleapis.com"
      metric     = urlencode("servicemanagement.googleapis.com/default_requests")
      limit      = urlencode("/min/project")
      dimensions = {}
      value      = "95"
    }
  ]
}
