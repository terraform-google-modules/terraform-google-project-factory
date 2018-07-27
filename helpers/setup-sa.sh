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

# Organization ID
ORG_ID=$1

# Host project
HOST_PROJECT=$2

# Service Account ID
SA_ID=$3

# Grant roles/resourcemanager.organizationViewer to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.organizationViewer"

# Grant roles/resourcemanager.projectCreator to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectCreator"

# Grant roles/billing.user to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/billing.user"

# Grant roles/compute.xpnAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.xpnAdmin"

# Grant roles/compute.networkAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin"

# Grant roles/iam.serviceAccountAdmin to the service account on the organization
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountAdmin"

# Grant roles/resourcemanager.projectIamAdmin to the service account on the host project
gcloud projects add-iam-policy-binding \
  "${HOST_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin"
