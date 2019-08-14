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

provider "gsuite" {
  credentials             = file(local.credentials_file_path)
  impersonated_user_email = var.admin_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]

  version = "~> 0.1.9"
}

resource "google_folder" "prod" {
  display_name = "gcp-prod"
  parent       = "organizations/${var.organization_id}"
}

module "project-prod-gke" {
  source            = "../../modules/gsuite_enabled"
  random_project_id = true
  name              = "hierarchy-sample-prod-gke"
  org_id            = var.organization_id
  billing_account   = var.billing_account
  folder_id         = google_folder.prod.id
  credentials_path  = local.credentials_file_path
}

module "project-factory" {
  source            = "../../modules/gsuite_enabled"
  random_project_id = true
  name              = "hierarchy-sample-factory"
  org_id            = var.organization_id
  billing_account   = var.billing_account
  folder_id         = google_folder.prod.id
  credentials_path  = local.credentials_file_path
}

