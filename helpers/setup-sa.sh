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
set -u

# Organization ID
ORG_ID="$(gcloud organizations list --format="value(ID)" --filter="$1")"

if [[ $ORG_ID == "" ]];
then
  echo "The organization id provided does not exist. Exiting."
  exit 1;
fi

# Host project
HOST_PROJECT="$(gcloud projects list --format="value(projectId)" --filter="$2")"

if [[ $HOST_PROJECT == "" ]];
then
  echo "The host project does not exist. Exiting."
  exit 1;
fi

# Service Account creation
SA_NAME="project-factory-${RANDOM}"
SA_ID="${SA_NAME}@${HOST_PROJECT}.iam.gserviceaccount.com"
STAGING_DIR="${PWD}"
KEY_FILE="${STAGING_DIR}/credentials.json"

gcloud iam service-accounts \
    --project ${HOST_PROJECT} create ${SA_NAME} \
    --display-name ${SA_NAME}

echo "Downloading key to credentials.json..."

gcloud iam service-accounts keys create ${KEY_FILE} \
    --iam-account ${SA_ID} \
    --user-output-enabled false

echo "Applying permissions for org $ORG_ID and project $HOST_PROJECT..."
# Grant roles/resourcemanager.organizationViewer to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.organizationViewer" \
  --user-output-enabled false

# Grant roles/resourcemanager.projectCreator to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectCreator" \
  --user-output-enabled false

# Grant roles/billing.user to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/billing.user" \
  --user-output-enabled false

# Grant roles/compute.xpnAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.xpnAdmin" \
  --user-output-enabled false

# Grant roles/compute.networkAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin" \
  --user-output-enabled false

# Grant roles/iam.serviceAccountAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountAdmin" \
  --user-output-enabled false

# Grant roles/resourcemanager.projectIamAdmin to the service account on the host project
gcloud projects add-iam-policy-binding \
  "${HOST_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --user-output-enabled false

echo "All done."
