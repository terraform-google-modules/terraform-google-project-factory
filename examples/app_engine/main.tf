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
  credentials             = "${file(local.credentials_file_path)}"
  impersonated_user_email = "${var.admin_email}"
}

module "project-factory" {
  source            = "../../modules/gsuite_enabled"
  random_project_id = "true"
  name              = "appeng-sample"
  org_id            = "${var.organization_id}"
  billing_account   = "${var.billing_account}"
  credentials_path  = "${local.credentials_file_path}"

  app_engine {
    location_id = "us-central"

    feature_settings = [
      {
        split_health_checks = true
      },
    ]
  }
}
