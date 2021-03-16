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

o=""
p=""
b=""
f=""
n=""

usage() {
  echo
  echo " Usage:"
  echo "     $0 -o <organization id> -p <project id> [-b <billing account id>] [-f <folder id>] [-n <service account name>]"
  echo "         organization id        (required)"
  echo "         project id             (required)"
  echo "         billing accout id      (optional)"
  echo "         folder id              (optional)"
  echo "         service account name   (optional)"
  echo
  echo " The billing account id is required if owned by a different organization"
  echo " than the Seed Project organization."
  echo
  exit 1
}

# Check for input variables
while getopts ":ho:p:b:f:n:" OPT; do
  # shellcheck disable=SC2213
  case ${OPT} in
    o )
      o=$OPTARG
      ;;
    p )
      p=$OPTARG
      ;;
    b )
      b=$OPTARG
      ;;
    f )
      f=$OPTARG
      ;;
    n )
      n=$OPTARG
      ;;
    : )
      echo
      echo " Error: option -${OPTARG} requires an argument"
      usage
      ;;
   \? )
      echo
      echo " Error: invalid option -${OPTARG}"
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Check for required input variables
if [ -z "${o}" ] || [ -z "${p}" ]; then
  echo
  echo " Error: -o <organization id> and -p <project id> required."
  usage
fi

# Organization ID
echo "Verifying organization..."
ORG_ID="$(gcloud organizations list --format="value(ID)" --filter="$o")"

if [[ $ORG_ID == "" ]]; then
  echo "The organization id provided does not exist. Exiting."
  exit 1;
fi

# Seed Project
echo "Verifying project..."
SEED_PROJECT="$(gcloud projects describe --format="value(projectId)" "$p")"

if [[ $SEED_PROJECT == "" ]]; then
  echo "The Seed Project does not exist. Exiting."
  exit 1;
fi

# Billing account
if [ -z "${b}" ]; then
  echo "Skipping billing account verification... (parameter not passed)"
else
  echo "Verifying billing account..."
  BILLING_ACCOUNT="$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" --filter="$b")"

  if [[ $BILLING_ACCOUNT == "" ]]; then
    echo "The billing account does not exist. Exiting."
    exit 1;
  fi
fi

# Project Folder
if [ -z "${f}" ]; then
  echo "Skipping project folder verification... (parameter not passed)"
  FOLDER_ID=""
else
  echo "Verifying project folder..."
  FOLDER_ID="$(gcloud resource-manager folders list --format="value(ID)" --organization="$o" --filter="$f")"

  if [[ $FOLDER_ID == "" ]]; then
    echo "The project folder does not exist. Exiting."
    exit 1;
  fi
fi

# Seed Service Account creation
if [ -z "${n}" ]; then
    SA_NAME="project-factory-${RANDOM}"
else
    SA_NAME="$n"
fi
SA_ID="${SA_NAME}@${SEED_PROJECT}.iam.gserviceaccount.com"
STAGING_DIR="${PWD}"
KEY_FILE="${STAGING_DIR}/credentials.json"

echo "Creating Seed Service Account named $SA_ID..."
gcloud iam service-accounts \
  --project "${SEED_PROJECT}" create "${SA_NAME}" \
  --display-name "${SA_NAME}"

echo "Downloading key to credentials.json..."
gcloud iam service-accounts keys create "${KEY_FILE}" \
  --iam-account "${SA_ID}" \
  --user-output-enabled false

if [[ $FOLDER_ID == "" ]]; then
  echo "Skipping grant roles on project folder... (parameter not passed)"
else
  echo "Applying permissions for folder $FOLDER_ID..."
  # Grant roles/resourcemanager.folderViewer to the Seed Service Account on the folder
  echo "Adding role roles/resourcemanager.folderViewer..."
  gcloud resource-manager folders add-iam-policy-binding \
    "${FOLDER_ID}" \
    --member="serviceAccount:${SA_ID}" \
    --role="roles/resourcemanager.folderViewer" \
    --user-output-enabled false
fi

echo "Applying permissions for org $ORG_ID and project $SEED_PROJECT..."
# Grant roles/resourcemanager.organizationViewer to the Seed Service Account on the organization
echo "Adding role roles/resourcemanager.organizationViewer..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.organizationViewer" \
  --user-output-enabled false

# Grant roles/resourcemanager.projectCreator to the service account on the organization
echo "Adding role roles/resourcemanager.projectCreator..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectCreator" \
  --user-output-enabled false

# Grant roles/billing.user to the service account on the organization
echo "Adding role roles/billing.user..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/billing.user" \
  --user-output-enabled false

# Grant roles/compute.xpnAdmin to the service account on the organization
echo "Adding role roles/compute.xpnAdmin..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.xpnAdmin" \
  --user-output-enabled false

# Grant roles/compute.networkAdmin to the service account on the organization
echo "Adding role roles/compute.networkAdmin..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin" \
  --user-output-enabled false

# Grant roles/iam.serviceAccountAdmin to the service account on the organization
echo "Adding role roles/iam.serviceAccountAdmin..."
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountAdmin" \
  --user-output-enabled false

# Grant roles/resourcemanager.projectIamAdmin to the Seed Service Account on the Seed Project
echo "Adding role roles/resourcemanager.projectIamAdmin..."
gcloud projects add-iam-policy-binding \
  "${SEED_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --user-output-enabled false

# Enable required API's
echo "Enabling APIs..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services enable \
  cloudbilling.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services enable \
  billingbudgets.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services enable \
  iam.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services enable \
  admin.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services enable \
  appengine.googleapis.com \
  --project "${SEED_PROJECT}"

# enable the billing account
if [[ ${BILLING_ACCOUNT:-} != "" ]]; then
  echo "Enabling the billing account..."
  gcloud beta billing accounts get-iam-policy "$BILLING_ACCOUNT" > policy-tmp-$$.yml
  unamestr=$(uname)
  if [ "$unamestr" = 'Darwin' ] || [ "$unamestr" = 'Linux' ]; then
    sed -i.bak -e "/^etag:.*/i \\
- members:\\
\ \ - serviceAccount:${SA_ID}\\
\ \ role: roles/billing.user" policy-tmp-$$.yml && rm policy-tmp-$$.yml.bak
    gcloud beta billing accounts set-iam-policy "$BILLING_ACCOUNT" policy-tmp-$$.yml
  else
    echo "Could not set roles/billing.user on service account $SERVICE_ACCOUNT.\
    Please perform this manually."
  fi
  rm -f policy-tmp-$$.yml
fi

echo "All done."
