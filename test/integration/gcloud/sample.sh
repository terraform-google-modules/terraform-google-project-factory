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


#################################################################
#   PLEASE FILL THE VARIABLES WITH VALID VALUES FOR TESTING     #
#   DO NOT REMOVE ANY OF THE VARIABLES                          #
#################################################################

## These values you *MUST* modify to match your environment
export ORG_ID="0000000000"
export BILLING_ACCOUNT="XXXXXX-XXXXXX-XXXXXX"
export SHARED_VPC="gcp-foundation-shared-host"
export SA_GROUP="gcp-svc-accounts@example.com"
export USAGE_BUCKET_NAME="gcp-foundation-usage-export"
export GSUITE_ADMIN_ACCOUNT="admin@clearify.com"
export CREDENTIALS_PATH="$HOME/sa-key.json"

## These values you can potentially leave at the defaults
export PROJECT_NAME="pf-test-integration"
export PROJECT_RANDOM_ID="true"
export GROUP_NAME="test-group$RANDOM"
export CREATE_GROUP="true"
export FOLDER_ID=""
export GROUP_ROLE="roles/editor"
export LOCATION_ID="us-central"
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS_PATH
