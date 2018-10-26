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
export TF_VAR_sa_role="roles/editor"
export TF_VAR_domain="example.com"
export TF_VAR_gsuite_admin_account="user@${TF_VAR_domain}"
export TF_VAR_credentials_path="credentials.json"
