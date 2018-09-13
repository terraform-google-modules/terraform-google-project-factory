#!/bin/bash

# Array with service accounts data
ARRAY="$1"

# Host project where subnet is
PROJECT=$2

# Subnets to add policy
SUBNETS=$3

# Credentials path
CREDENTIALS=$4

# Operation, either "add" or "destroy"
OPERATION="$5"

# Role to grant
ROLE="roles/compute.networkUser"

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=$CREDENTIALS

# Create json temp file
FILE_NAME="temp_$RANDOM.json"
touch $FILE_NAME
chown $(whoami) $FILE_NAME

# Helper function for string splitting
function get_sub_string_split(){
  STRING="$1"
  SEPARATOR="$2"
  PART=$3
  IFS="$SEPARATOR" read -ra SPLIT <<< $STRING
  echo "${SPLIT[$PART]}"
}

# Writes a new policy to file
function write_new_policy(){
  echo "Writing policy from scratch"
  SERVICE_ACCOUNT="$1"
  cat <<EOF > $FILE_NAME
{
  "bindings": [
    {
      "members": [
        "serviceAccount:$SERVICE_ACCOUNT"
      ],
      "role": "$ROLE"
    }
  ],
}
EOF
}

# Updates a policy that already has the role and some members
function update_policy(){
  echo "Updating policy"
  CURRENT_POLICY="$1"
  SERVICE_ACCOUNT="$2"
  OPERATION="$3"
  if [[ "$OPERATION" = "add" ]]
  then
    CURRENT_POLICY=$(echo "$CURRENT_POLICY" | jq -r --arg ROLE "$ROLE" --arg SERVICE_ACCOUNT "$SERVICE_ACCOUNT" '(.bindings?[]? | select(.role == $ROLE) | .members) |= .+ ["serviceAccount:"+$SERVICE_ACCOUNT]')
  elif [[ "$OPERATION" = "destroy" ]]
  then
    CURRENT_POLICY=$(echo "$CURRENT_POLICY" | jq -r --arg ROLE "$ROLE" --arg SERVICE_ACCOUNT "$SERVICE_ACCOUNT" '(.bindings?[]? | select(.role == $ROLE) | .members) |= .- ["serviceAccount:"+$SERVICE_ACCOUNT]')
  fi

  echo "$CURRENT_POLICY" > "$FILE_NAME"
}

# Add/remove a binding to policy
function add_binding(){
  echo "Adding new binding"
  CURRENT_POLICY="$1"
  SERVICE_ACCOUNT="$2"
  CURRENT_POLICY=$(echo "$CURRENT_POLICY" | jq -r --arg SERVICE_ACCOUNT "$SERVICE_ACCOUNT" --arg ROLE "$ROLE" '.bindings? |= .+ [{"members":["serviceAccount:"+$SERVICE_ACCOUNT]} + {"role":$ROLE} ]')
  echo "$CURRENT_POLICY" > "$FILE_NAME"
}

# Cleans the file
function clean_file(){
  echo "" > $FILE_NAME
}

# Get service accounts list
SERVICE_ACCOUNTS=$(echo "$ARRAY" | jq -r '.[] | select(.network_access == "1") | .account_id')

# Service accounts to array
IFS=$'\n' read -d ' ' -a SERVICE_ACCOUNTS_ARRAY <<< "$SERVICE_ACCOUNTS"

# Set the iam-policy per each service account and per each subnet
for SERVICE_ACCOUNT in "${SERVICE_ACCOUNTS_ARRAY[@]}"
do
  #Formatted service account
  SERVICE_ACCOUNT_FMT="$SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com"

  # Subnets formatting
  SUBNETS_FMT=$(echo "$SUBNETS" | jq -r '.[]')

  # Subnets array
  IFS=$'\n' read -d ' ' -a SUBNETS_ARRAY <<< "$SUBNETS_FMT"

  for SUBNET in "${SUBNETS_ARRAY[@]}"
  do

    # Var to control whether to apply the command or not
    APPLY_COMMAND=1

    # Subnet data retrieval
    NAME=$(get_sub_string_split "$SUBNET" "/" 5)
    REGION=$(get_sub_string_split "$SUBNET" "/" 3)
    PROJECT_HOST=$(get_sub_string_split "$SUBNET" "/" 1)

    # We take the current policy
    CURRENT_POLICY=$(gcloud beta compute networks subnets get-iam-policy "$NAME" --region="$REGION" --project="$PROJECT_HOST" --format=json)
    # If it's void, we write a new one
    if [[ $(echo "$CURRENT_POLICY" | jq '.bindings?[]?') == "" ]]
    then
      if [[ "$OPERATION" = "add" ]]
      then
        write_new_policy "$SERVICE_ACCOUNT_FMT"
      elif [[ "$OPERATION" = "destroy" ]]
      then
        APPLY_COMMAND=0
      fi

    # If it already has a binding with the role, we update the policy
    elif [[ $(echo "$CURRENT_POLICY" | jq -r --arg ROLE "$ROLE" '.bindings?[]? | select(.role == $ROLE)') != "" ]];
    then
      update_policy "$CURRENT_POLICY" "$SERVICE_ACCOUNT_FMT" "$OPERATION"
    elif [[ "$OPERATION" = "add" ]]
    then
      add_binding "$CURRENT_POLICY" "$SERVICE_ACCOUNT_FMT"
    fi

    # Perform the command
    if [[ $APPLY_COMMAND -eq 1 ]]
    then
      gcloud beta compute networks subnets set-iam-policy "$NAME" $FILE_NAME --region "$REGION" --project "$PROJECT_HOST" --quiet
    fi
    clean_file
  done

done

rm -f $FILE_NAME
