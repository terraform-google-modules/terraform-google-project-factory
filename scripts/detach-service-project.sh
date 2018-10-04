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

HOST_PROJECT_ID=$1
CREDENTIALS=$2
SERVICE_PROJECT_ID=$3

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

SERVICE_PROJECTS_LIST=$(gcloud --project="$HOST_PROJECT_ID" compute shared-vpc list-associated-resources "$HOST_PROJECT_ID" || exit 1)

if [[ $SERVICE_PROJECTS_LIST = *"$SERVICE_PROJECT_ID"* ]]; then
    echo "Detaching service project $SERVICE_PROJECT_ID from host project $HOST_PROJECT_ID"
    gcloud --project="$HOST_PROJECT_ID" compute shared-vpc associated-projects remove "$SERVICE_PROJECT_ID" --host-project "$HOST_PROJECT_ID" --quiet
else
    echo "Service project $SERVICE_PROJECT_ID is not attached to host project $HOST_PROJECT_ID."
    exit 1
fi
