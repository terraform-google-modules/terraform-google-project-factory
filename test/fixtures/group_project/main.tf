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

module "test-create-group" {
  source            = "../../../modules/gsuite_enabled"
  random_project_id = true
  name              = "test-create-group"
  domain            = var.domain
  folder_id         = var.folder_id
  org_id            = var.org_id
  billing_account   = var.billing_account
  create_group      = true
  group_name        = "test-create-group"
  credentials_path  = var.gsuite_sa_credentials_path
  # api_sa_group      = var.api_sa_group

  default_service_account     = "delete"
  disable_services_on_destroy = "false"

}
