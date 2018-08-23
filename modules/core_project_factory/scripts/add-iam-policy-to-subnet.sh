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


# Subnet to add policy
SUBNETS=$1

# Host project where subnet is
HOST_PROJECT=$2

# Region where subnet is
REGION=$3

# Service Account to grant role
SERVICE_ACCOUNT=$4

# Group to grant role
GROUP=$5

CREDENTIALS=$6

# Create json temp file
FILE_NAME="temp_$RANDOM.json"
touch "$FILE_NAME"
chown "$(whoami)" "$FILE_NAME"
cat <<EOF > $FILE_NAME
{
  "bindings": [
    {
      "members": [
        "serviceAccount:$SERVICE_ACCOUNT",
        "group:$GROUP"
      ],
      "role": "roles/compute.networkUser"
    }
  ],
}
EOF

# Construct subnet array
IFS=',' read -r -a SUBNETS_ARRAY <<< "$SUBNETS"

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

#Perform command for each subnet
for SUBNET in "${SUBNETS_ARRAY[@]}"
do
  gcloud beta compute networks subnets set-iam-policy "$SUBNET" "$FILE_NAME" \
    --region "$REGION" \
    --project "$HOST_PROJECT" --quiet
done

rm -f $FILE_NAME
