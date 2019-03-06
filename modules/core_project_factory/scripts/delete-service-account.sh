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

PROJECT_ID=$1
SA_ID=$2
CREDENTIALS=$3

if [[ -n "${CREDENTIALS}" ]]; then
  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$CREDENTIALS"
elif [[ -n "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$GOOGLE_APPLICATION_CREDENTIALS"
fi

SA_LIST=$(gcloud --project="$PROJECT_ID" iam service-accounts list || exit 1)

if [[ $SA_LIST = *"$SA_ID"* ]]; then
    echo "Deleting service account $SA_ID in project $PROJECT_ID"
    gcloud iam service-accounts delete --quiet --project="$PROJECT_ID" "$SA_ID"
else
    echo "Service account not listed. It appears to have already been deleted."
fi
