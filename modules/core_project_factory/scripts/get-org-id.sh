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


set -e

CONTROL_FLAG=-1
BASH_ORG_ID=""
PARAM_ID=$1
CREDENTIALS=$2

# If the folder_id == -1 then the org_id is ""
if [[ "$PARAM_ID" = "-1" ]];
then
  jq -n --arg org_id "" '{"org_id":$org_id}' && exit 0
fi

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

while [[ $CONTROL_FLAG = -1 ]];
do
  # Retrieve the parent id of folder
  BASH_ORG_ID=$(gcloud alpha resource-manager folders describe "$PARAM_ID" --format="flattened[no-pad](parent)")
  # Save the current parent for next iteration, if needed
  PARAM_ID=$(echo "$BASH_ORG_ID" | cut -d'/' -f 2)
  # If parent is a organization, end while loop
  if [[ $BASH_ORG_ID = *"organizations"* ]];
  then
    CONTROL_FLAG=0
  fi
done

jq -n --arg org_id "$PARAM_ID" '{"org_id":$org_id}'
