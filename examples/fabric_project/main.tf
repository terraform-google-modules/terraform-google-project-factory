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
  prefix = var.prefix == "" ? random_string.prefix.result : var.prefix
}

resource "random_string" "prefix" {
  length  = 30 - length(var.name) - 1
  upper   = false
  numeric = false
  special = false
}

module "fabric-project" {
  source  = "terraform-google-modules/project-factory/google//modules/fabric-project"
  version = "~> 14.0"

  activate_apis   = var.activate_apis
  billing_account = var.billing_account
  name            = var.name
  owners          = var.owners
  parent          = var.parent
  prefix          = local.prefix
}
