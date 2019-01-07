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
  args_missing = "${var.name != "" && var.org_id == "" && var.domain == "" ? 1 : 0}"
  domain       = "${var.domain != "" ? var.domain : var.org_id != "" ? join("", data.google_organization.org.*.domain) : ""}"
  email        = "${format("%s@%s", var.name, local.domain)}"
}

resource "null_resource" "args_missinG" {
  count = "${local.args_missing}"

  "ERROR: Variable `group_name` was passed. Please provide either `org_id` or `domain` variables" = "true"
}

/*****************************************
  Organization info retrieval
 *****************************************/
data "google_organization" "org" {
  count        = "${var.org_id == "" ? 0 : 1}"
  organization = "${var.org_id}"
}
