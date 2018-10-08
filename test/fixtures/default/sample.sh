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

## These values you *MUST* motify to match your environment
export TF_VAR_org_id="000000000000"
export TF_VAR_billing_account="000000-000000-000000"
export TF_VAR_sa_group=""
export TF_VAR_sa_role=""
export TF_VAR_domain="example.com"
export TF_VAR_gsuite_admin_account="user@${TF_VAR_domain}"
export TF_VAR_credentials_path="credentials.json"

## These values you can potentially leave at the defaults
export TF_VAR_folder_id=""
export TF_VAR_name="$USER-pf-test-integration"
export TF_VAR_random_project_id="true"
export TF_VAR_create_group="false"
export TF_VAR_group_name="test_sa_group"
export TF_VAR_group_role="roles/viewer"
export TF_VAR_region="us-east4"
export TF_VAR_usage_bucket_name=""
export TF_VAR_usage_bucket_prefix=""
export TF_VAR_activate_apis='["container.googleapis.com", "compute.googleapis.com"]'

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$TF_VAR_credentials_path"
