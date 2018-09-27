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

TESTDIR=${BASH_SOURCE%/*}

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

function create_inspec_attributes_file() {
  echo -n > inspec-attributes.yml

  if [ "$SA_ROLE" != "" ]; then
    echo "sa_role: $SA_ROLE" >> inspec-attributes.yml
  fi

  if [ "$USAGE_BUCKET_NAME" != "" ]; then
    echo "usage_bucket_name: $USAGE_BUCKET_NAME" >> inspec-attributes.yml
  fi

  if [ "$USAGE_BUCKET_PREFIX" != "" ]; then
    echo "usage_bucket_prefix: $USAGE_BUCKET_PREFIX" >> inspec-attributes.yml
  fi

  if [ "$SHARED_VPC" != "" ]; then
    echo "shared_vpc: $SHARED_VPC" >> inspec-attributes.yml
  fi

  if [ "$GROUP_ROLE" != "" ]; then
    echo "group_role: $GROUP_ROLE" >> inspec-attributes.yml
  fi

  echo "gsuite_admin_account: $GSUITE_ADMIN_ACCOUNT" >> inspec-attributes.yml
  echo "region: $REGION" >> inspec-attributes.yml
}

# Preparing environment
cd "$TESTDIR" || exit
activate_config
create_terraform_tfvars_file
create_inspec_attributes_file
