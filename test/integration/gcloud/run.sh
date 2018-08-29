#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TEMPDIR=$(pwd)/test/integration/tmp
TESTDIR=${BASH_SOURCE%/*}

# Activate test working directory
function make_testdir() {
  mkdir -p "$TEMPDIR"
  cp -r "$TESTDIR/*" "$TEMPDIR"
}

# Activate test config
function activate_config() {
  # shellcheck disable=SC1091
  source config.sh
  echo "$PROJECT_NAME"
}

# Cleans the workdir
function clean_workdir() {
  rm -rf "$TEMPDIR"

  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=""
  unset CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE
}

# Creates the main.tf file for Terraform
function create_main_tf_file() {
  echo "Creating main.tf file"
  touch main.tf
  cat <<EOF > main.tf
locals {
  credentials_file_path    = "$CREDENTIALS_PATH"
}

provider "google" {
  credentials              = "\${file(local.credentials_file_path)}"
}

provider "gsuite" {
  credentials              = "\${file(local.credentials_file_path)}"
  impersonated_user_email  = "$GSUITE_ADMIN_ACCOUNT"
  oauth_scopes             = [
                               "https://www.googleapis.com/auth/admin.directory.group",
	                           "https://www.googleapis.com/auth/admin.directory.group.member"
                             ]
}
module "project-factory" {
  source                   = "../../../modules/gsuite_enabled/"
  name                     = "$PROJECT_NAME"
  random_project_id        = "$PROJECT_RANDOM_ID"
  org_id                   = "$ORG_ID"
  usage_bucket_name        = "$USAGE_BUCKET_NAME"
  usage_bucket_prefix      = "$USAGE_BUCKET_PREFIX"
  billing_account          = "$BILLING_ACCOUNT"
  create_group             = "$CREATE_GROUP"
  group_role               = "$GROUP_ROLE"
  group_name               = "$GROUP_NAME"
  shared_vpc               = "$SHARED_VPC"
  sa_group                 = "$SA_GROUP"
  folder_id                = "$FOLDER_ID"
  activate_apis            = ["compute.googleapis.com", "container.googleapis.com"]
  credentials_path         = "\${local.credentials_file_path}"
  app_engine {
    location_id = "$REGION"
    auth_domain = "$(echo $GSUITE_ADMIN_ACCOUNT | cut -d '@' -f2)"

    feature_settings = [
      {
        split_health_checks = false
      },
    ]
  }
}
EOF
}

# Creates the outputs.tf file
function create_outputs_file() {
  echo "Creating outputs.tf file"
  touch outputs.tf
  cat <<'EOF' > outputs.tf
output "project_info_example" {
  value       = "${module.project-factory.project_id}"
}

output "project_info_number" {
  value       = "${module.project-factory.project_number}"
}

output "domain_example" {
  value       = "${module.project-factory.domain}"
}

output "group_email_example" {
  value       = "${module.project-factory.group_email}"
}
EOF
}

# Execute bats tests
function run_bats() {
  # Call to bats
  echo "Test to execute: $(bats integration.bats -c)"
  bats integration.bats
}

# Preparing environment
make_testdir
cd "$TEMPDIR" || exit
activate_config
create_main_tf_file
create_outputs_file

# Call to bats
run_bats

# # # Clean the environment
cd - || exit
clean_workdir
echo "Integration test finished"
