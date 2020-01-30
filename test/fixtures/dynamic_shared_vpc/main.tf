/**
 * Copyright 2019 Google LLC
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

module "example" {
  source               = "../../../examples/shared_vpc"
  organization_id      = var.org_id
  folder_id            = var.folder_id
  billing_account      = var.billing_account
  host_project_name    = "pf-ci-shared2-host-${var.random_string_for_testing}"
  service_project_name = "pf-ci-shared2-svc-${var.random_string_for_testing}"
}
