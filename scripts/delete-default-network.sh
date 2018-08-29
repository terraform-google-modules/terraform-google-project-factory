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


PROJECT=$1
CREDENTIALS=$2

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

echo "Deleting the default network in $PROJECT"

gcloud compute firewall-rules list --project="$PROJECT" --format='value(name)' | while read -r line ;
do
    :
    RULE_NAME=$line
    gcloud compute firewall-rules delete "$RULE_NAME" --quiet --project="$PROJECT"
done

gcloud compute networks delete default --quiet --project="$PROJECT"
