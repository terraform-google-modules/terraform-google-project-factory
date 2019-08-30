#!/usr/bin/env bash

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

echo "#!/usr/bin/env bash" > ../source.sh

project_id=$(terraform output project_id)
echo "export TF_VAR_project_id='$project_id'" >> ../source.sh
echo "export TF_VAR_shared_vpc='$project_id'" >> ../source.sh

# shellcheck disable=SC2086
terraform output sa_key | base64 --decode > ../credentials_pfactory.json

creds_full_path=$(cd .. && pwd)
echo "export TF_VAR_credentials_path='$creds_full_path/credentials_pfactory.json'" >> ../source.sh

folder_id=$(terraform output folder_id)
echo "export TF_VAR_folder_id='$folder_id'" >> ../source.sh

billing_account=$(terraform output billing_account)
echo "export TF_VAR_billing_account='$billing_account'" >> ../source.sh

org_id=$(terraform output org_id)
echo "export TF_VAR_org_id='$org_id'" >> ../source.sh

random_string_for_testing=$(terraform output random_string_for_testing)
echo "export TF_VAR_random_string_for_testing='$random_string_for_testing'" >> ../source.sh

gsuite_admin_email=$(terraform output gsuite_admin_email)
echo "export TF_VAR_gsuite_admin_account='$gsuite_admin_email'" >> ../source.sh

gsuite_domain=$(terraform output gsuite_domain)
echo "export TF_VAR_domain='$gsuite_domain'" >> ../source.sh

gsuite_group=$(terraform output gsuite_group)
echo "export TF_VAR_group_name='$gsuite_group'" >> ../source.sh

