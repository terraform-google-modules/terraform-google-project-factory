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

SUBNETS_LIST=$1
HOST_PROJECT=$2
CREDENTIALS=$3
RESULT="{}"

if [[ "$SUBNETS_LIST" == "-1" ]];
then
  echo "$RESULT" && exit 0
fi

# Construct subnet array
IFS=',' read -r -a SUBNETS_ARRAY <<< "$SUBNETS_LIST"

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

#Perform region retrieval for each subnet
for SUBNET in "${SUBNETS_ARRAY[@]}"
do
  # We try to get the region
  REGION=$(export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$CREDENTIALS"; gcloud compute networks subnets list --project "$HOST_PROJECT" --format="value[separator=' '](name,region)" | grep "$SUBNET" | cut -d' ' -f 2 | head -n 1)
  if [[ "$REGION" != "" ]];
  then
    RESULT=$(echo "$RESULT" | jq --arg subnet "$SUBNET" --arg region "$REGION" '(. |= .+ { ($subnet): $region } )')
  fi
done

echo "$RESULT"