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

resource "google_service_account" "project_service_accounts" {
  count = "${length(var.service_accounts)}"

  account_id   = "${lookup(var.service_accounts[count.index], "account_id")}"
  display_name = "${lookup(var.service_accounts[count.index], "description")}"
  project      = "${var.project_id}"
}

resource "null_resource" "service_accounts_role_granting" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/service_accounts_role_granting.sh '${jsonencode(var.service_accounts)}' '${var.project_id}' '${var.credentials_path}' add"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/service_accounts_role_granting.sh '${jsonencode(var.service_accounts)}' '${var.project_id}' '${var.credentials_path}' destroy"
    when    = "destroy"
  }

  triggers {
      service_accounts = "${jsonencode(var.service_accounts)}"
  }

  depends_on = ["google_service_account.project_service_accounts"]
}

resource "null_resource" "service_accounts_vpc_subnets_sharing" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/service_accounts_vpc_subnets_sharing.sh '${jsonencode(var.service_accounts)}' '${var.project_id}' '${jsonencode(var.shared_vpc_subnets)}' '${var.credentials_path}' add"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/service_accounts_vpc_subnets_sharing.sh '${jsonencode(var.service_accounts)}' '${var.project_id}' '${jsonencode(var.shared_vpc_subnets)}' '${var.credentials_path}' destroy"
    when    = "destroy"
  }

  triggers {
      service_accounts   = "${jsonencode(var.service_accounts)}"
      shared_vpc_subnets = "${jsonencode(var.shared_vpc_subnets)}"
  }

  depends_on = ["google_service_account.project_service_accounts", "null_resource.service_accounts_role_granting"]
}

resource "null_resource" "service_accounts_groups_membership" {
  count = "${var.impersonated_user_email != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/service_accounts_group_membership.py --service_accounts '${jsonencode(var.service_accounts)}' --project_id '${var.project_id}' --path '${var.credentials_path}' --email '${var.impersonated_user_email}' --action add"
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/service_accounts_group_membership.py --service_accounts '${jsonencode(var.service_accounts)}' --project_id '${var.project_id}' --path '${var.credentials_path}' --email '${var.impersonated_user_email}' --action destroy"
    when    = "destroy"
  }

  triggers {
      service_accounts = "${jsonencode(var.service_accounts)}"
  }

  depends_on = ["google_service_account.project_service_accounts"]
}
