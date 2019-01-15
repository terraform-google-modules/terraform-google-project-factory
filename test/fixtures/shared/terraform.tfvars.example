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

# Terraform variables for `test/fixtures/minimal`

# The organization ID where test projects will be created.
# Example source: `gcloud organizations list --format='get(name)'`
org_id = "000000000000"

# The billing account to attach to test projects.
# Example source: `gcloud alpha billing accounts list`
billing_account = "000000-000000-000000"

# The service account credentials to use when running Terraform.
credentials_path = "../../../credentials.json"

# The G Suite admin account to impersonate when managing G Suite groups and group membership
gsuite_admin_account = "admin@example.com"

# The Shared VPC host project.
#
# Example:
#
# ```
# org_id=$(gcloud organizations list --format='get(name)')
# gcloud compute shared-vpc organizations list-host-projects $org_id
# ```
shared_vpc = "host-vpc-project-id"

# The folder ID where the project will be created.
# Example source: `gcloud alpha resource-manager folders list --organization $(gcloud organizations list --format='get(name)')`
# folder_id = "000000000000"


# The GCP domain name
# Example source: `domain=$(gcloud organizations list --format='get(displayName)')`
domain = "example.com"

# A G Suite group to create and give access to the test projects
group_name = "my-developers"

##### Optional variables ####

# Variables for setting GCE usage export
# usage_bucket_name = "usage-export-bucket"
# usage_bucket_prefix = "pfactory-test-"


# A G Suite group to store service accounts
# sa_group = "my-svc-account@example.com"

