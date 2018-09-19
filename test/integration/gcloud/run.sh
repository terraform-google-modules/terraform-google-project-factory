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
  cp -r "$TESTDIR"/* "$TEMPDIR"
}

# Activate test config
function activate_config() {
  # shellcheck disable=SC1091
  source config.sh
  echo "$PROJECT_NAME"
}

# Convert environment variables defined in 'config.sh' into terraform variables.
function create_terraform_tfvars_file() {
  cat <<EOF > terraform.tfvars
credentials_path="$CREDENTIALS_PATH"
name="$PROJECT_NAME"
random_project_id="$PROJECT_RANDOM_ID"
org_id="$ORG_ID"
folder_id="$FOLDER_ID"
usage_bucket_name="$USAGE_BUCKET_NAME"
usage_bucket_prefix="$USAGE_BUCKET_PREFIX"
billing_account="$BILLING_ACCOUNT"
group_name="$GROUP_NAME"
create_group="$CREATE_GROUP"
group_role="$GROUP_ROLE"
shared_vpc="$SHARED_VPC"
sa_role="$SA_ROLE"
sa_group="$SA_GROUP"
activate_apis=["container.googleapis.com", "compute.googleapis.com"]
region="$REGION"
gsuite_admin_account="$GSUITE_ADMIN_ACCOUNT"
domain="$(echo "$GSUITE_ADMIN_ACCOUNT" | cut -d '@' -f2)"
EOF
}

# Preparing environment
make_testdir
cd "$TEMPDIR" || exit
activate_config
create_terraform_tfvars_file

# # # Clean the environment
cd - || exit
# clean_workdir
echo "Integration test finished"
