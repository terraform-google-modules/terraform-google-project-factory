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

#set -e

# Store service_account variable
ARRAY="$1"
# Either "roles" or "groups"
PROJECT="$2"
# Credentials
CREDENTIALS="$3"
# Operation, either "add" or "destroy"
OPERATION="$4"

# Export credentials for gcloud commands
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

# Get service accounts list
SERVICE_ACCOUNTS=$(echo "$ARRAY" | jq -r '.[].account_id')

# Service accounts to array
IFS=$'\n' read -d ' ' -a SERVICE_ACCOUNTS_ARRAY <<< "$SERVICE_ACCOUNTS"

# Each service account's roles are formatted in one string
for SERVICE_ACCOUNT in "${SERVICE_ACCOUNTS_ARRAY[@]}"
do
  ROLES=$(echo "$ARRAY" | jq -r --arg service_account "$SERVICE_ACCOUNT" '.[] | select(.account_id==$service_account) | .roles[]?')
  IFS=$'\n' read -d ' ' -a ROLES_ARRAY <<< "$ROLES"

  for ROLE in "${ROLES_ARRAY[@]}"
  do
    if [[ "$OPERATION" = "add" ]]
    then
      gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com" --role="$ROLE"
      sleep 10 #intentional delay due to gcloud error when a policy is updated more than once in a row.
    elif [[ "$OPERATION" = "destroy" ]]
    then
      gcloud projects remove-iam-policy-binding "$PROJECT" --member="serviceAccount:$SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com" --role="$ROLE"
      sleep 5
    fi
  done
done