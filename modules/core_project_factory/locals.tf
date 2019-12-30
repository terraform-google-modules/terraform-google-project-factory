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

locals {
  root_path                      = abspath(path.root)
  preconditions_path             = join("/", [local.root_path, path.module, "scripts", "preconditions"])
  pip_requirements_absolute_path = join("/", [local.preconditions_path, "requirements.txt"])
  preconditions_py_absolute_path = join("/", [local.preconditions_path, "preconditions.py"])
  attributes = {
    billing_account             = var.billing_account
    org_id                      = var.org_id
    credentials_path            = var.credentials_path
    impersonate_service_account = var.impersonate_service_account
    folder_id                   = var.folder_id
    shared_vpc                  = var.shared_vpc
  }
  preconditions_command = "${var.python_interpreter_path} ${local.preconditions_py_absolute_path} %{for key, value in local.attributes}--${key}=\"${value}\" %{endfor}"
}
