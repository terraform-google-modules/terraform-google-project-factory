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

# Process arguments.
for i in "$@"
do
case $i in
    --project_id=*)
    PROJECT_ID="${i#*=}"
    shift
    ;;
    --sa_id=*)
    SA_ID="${i#*=}"
    shift
    ;;
    --credentials_path=*)
    CREDENTIALS="${i#*=}"
    shift
    ;;
    --impersonate-service-account=*)
    IMPERSONATE_SA="${i#*=}"
    shift
    ;;
    --action=*)
    SA_ACTION="${i#*=}"
    shift
    ;;
esac
done

# Setup credentials.
if [[ -n "${IMPERSONATE_SA}" ]]; then
  APPEND_IMPERSONATE="--impersonate-service-account ${IMPERSONATE_SA}"
else
  APPEND_IMPERSONATE=""
fi

if [[ -n "${CREDENTIALS}" ]]; then
  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$CREDENTIALS"
elif [[ -n "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$GOOGLE_APPLICATION_CREDENTIALS"
fi

# Function to delete the default service account.
delete_sa() {
  SA_LIST_COMMAND="gcloud iam service-accounts list $APPEND_IMPERSONATE --project=$PROJECT_ID"
  SA_LIST=$(${SA_LIST_COMMAND} || exit 1)

  if [[ $SA_LIST = *"$SA_ID"* ]]; then
      echo "Deleting service account $SA_ID in project $PROJECT_ID"
      SA_DELETE_COMMAND="gcloud iam service-accounts delete \
      --quiet $APPEND_IMPERSONATE \
      --project=$PROJECT_ID $SA_ID"
      ${SA_DELETE_COMMAND}
  else
      echo "Service account not listed. It appears to have already been deleted."
  fi
}

# Function to depriviledge the default service account.
depriviledge_sa() {
  EDITORS_LIST_COMMAND="gcloud projects get-iam-policy $PROJECT_ID \
  --flatten=bindings[].members \
  --format=table(bindings.role,bindings.members) \
  --filter=bindings.role:editor $APPEND_IMPERSONATE"
  EDITORS_LIST=$(${EDITORS_LIST_COMMAND} || exit 1)

  if [[ $EDITORS_LIST = *"$SA_ID"* ]]; then
      echo "Depriviledge service account $SA_ID in project $PROJECT_ID"
      SA_DEPRIV_COMMAND="gcloud projects remove-iam-policy-binding $PROJECT_ID \
      --member=serviceAccount:$SA_ID \
      --role=roles/editor \
      --project=$PROJECT_ID $APPEND_IMPERSONATE"
      ${SA_DEPRIV_COMMAND}
  else
      echo "Service account not listed. It appears to have already been depriviledged."
  fi
}

# Perform specified action of default service account.
case $SA_ACTION in
  delete)
      delete_sa ;;
  depriviledge)
      depriviledge_sa ;;
  keep)
      echo "Default service account set to keep, nothing to do."
      ;;
  *)
      echo "$SA_ACTION is not a valid action, nothing to do."
      ;;
esac



