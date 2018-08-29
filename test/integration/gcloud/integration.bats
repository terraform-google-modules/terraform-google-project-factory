#!/usr/bin/env bats

# #################################### #
#             Terraform tests          #
# #################################### #

@test "Ensure that Terraform configures the dirs and download the plugins" {

  run terraform init
  [ "$status" -eq 0 ]
}

@test "Ensure that Terraform updates the plugins" {

  run terraform get
  [ "$status" -eq 0 ]
}

@test "Terraform plan, ensure connection and creation of resources" {
  skip
  run terraform plan
  [ "$status" -eq 0 ]
  [[ "$output" =~ 11\ to\ add ]]
  [[ "$output" =~ 0\ to\ change ]]
  [[ "$output" =~ 0\ to\ destroy ]]
}

@test "Terraform apply" {
  skip
  run terraform apply -auto-approve
  [ "$status" -eq 0 ]
  [[ "$output" =~ 11\ added ]]
  [[ "$output" =~ 0\ changed ]]
  [[ "$output" =~ 0\ destroyed ]]
}

@test "Terraform plan setting of App Engine settings" {
  skip
  run terraform plan
  [ "$status" -eq 0 ]
  [[ "$output" =~ 0\ to\ add ]]
  [[ "$output" =~ 1\ to\ change ]]
  [[ "$output" =~ 0\ to\ destroy ]]
}

@test "Terraform apply" {
  skip
  run terraform apply -auto-approve
  [ "$status" -eq 0 ]
  [[ "$output" =~ 0\ added ]]
  [[ "$output" =~ 1\ changed ]]
  [[ "$output" =~ 0\ destroyed ]]
}

# #################################### #
#             gcloud tests             #
# #################################### #

@test "Test information about project $PROJECT_ID" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud config set project $PROJECT_ID
  run gcloud projects describe $PROJECT_ID --format=flattened[no-pad]
  [ "$status" -eq 0 ]
  [[ "${lines[5]}" = "projectId: $PROJECT_ID" ]]
}

@test "Test the correct apis are activated" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud services list
  [ "$status" -eq 0 ]
  [[ "${lines[2]}" = *"compute.googleapis.com"* ]]

  run gcloud services list
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" = *"appengine.googleapis.com"* ]]
}

@test "Test that project has the shared vpc associated (host project)" {

  PROJECT_ID="$(terraform output project_info_example)"
  GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud compute shared-vpc get-host-project $PROJECT_ID --format="get(name)"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" = "$SHARED_VPC" ]]
}

@test "Test project has only the expected service accounts" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud iam service-accounts list --format="get(email)"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" = "$PROJECT_ID@appspot.gserviceaccount.com" ]]
  [[ "${lines[1]}" = "project-service-account@$PROJECT_ID.iam.gserviceaccount.com" ]]
  [[ "${lines[3]}" = "" ]]
}

@test "Test Gsuite group $GROUP_EMAIL has role:$GROUP_ROLE on project" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud projects get-iam-policy $PROJECT_ID --format="list[compact]"
  [ "$status" -eq 0 ]
  [[ "$output" = *"u'role': u'$GROUP_ROLE', u'members': [u'group:$GROUP_EMAIL',"* ]]
}

@test "Test Gsuite group $GROUP_EMAIL has role:roles/iam.serviceAccountUser on service account" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud iam service-accounts get-iam-policy project-service-account@$PROJECT_ID.iam.gserviceaccount.com --format=flattened[no-pad]
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" = "bindings[0].members[0]: group:$GROUP_EMAIL" ]]
  [[ "${lines[1]}" = "bindings[0].role: roles/iam.serviceAccountUser" ]]
}

@test "Test project has enabled the usage report export to the bucket" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud compute project-info describe --format="flattened[no-pad](usageExportLocation)"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" = "usageExportLocation.bucketName: $USAGE_BUCKET_NAME" ]]
  [[ "${lines[1]}" = "usageExportLocation.reportNamePrefix: $USAGE_BUCKET_PREFIX" ]]
}

@test "Test both service account and GSuite group has role:roles/compute.networkUser on host project (shared VPC)" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"
  export PROJECT_NUM="$(terraform output project_info_number)"

  run gcloud projects get-iam-policy $SHARED_VPC --format=list[compact] --filter="bindings.role=roles/compute.networkUser AND bindings.members=group:$GROUP_EMAIL AND bindings.members=serviceAccount:project-service-account@$PROJECT_ID.iam.gserviceaccount.com"
  [ "$status" -eq 0 ]
  [[ "$output" = *"{u'role': u'roles/compute.networkUser', u'members': [u'group:$GROUP_EMAIL', u'serviceAccount:$PROJECT_NUM@cloudservices.gserviceaccount.com', u'serviceAccount:project-service-account@$PROJECT_ID.iam.gserviceaccount.com'"* ]]
}

@test "Test that the GKE service account has the role:roles/container.hostServiceAgentUser and role:/roles/compute.networkUser on host project (shared VPC for GKE)" {

  export PROJECT_NUM="$(terraform output project_info_number)"

  run gcloud projects get-iam-policy $SHARED_VPC --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:service-$PROJECT_NUM@container-engine-robot.iam.gserviceaccount.com"
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" = "roles/compute.networkUser" ]]
  [[ "${lines[2]}" = "roles/container.hostServiceAgentUser" ]]
}

@test "Test App Engine app created with the correct settings" {

  PROJECT_ID="$(terraform output project_info_example)"
  AUTH_DOMAIN="$(echo $GSUITE_ADMIN_ACCOUNT | cut -d '@' -f2)"

  run gcloud --project=${PROJECT_ID} app describe
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" = "authDomain: $AUTH_DOMAIN" ]]
  [[ "${lines[4]}" = "featureSettings: {}" ]]
  [[ "${lines[6]}" = "id: $PROJECT_ID}" ]]
  [[ "${lines[7]}" = "name: apps/$PROJECT_ID" ]]
  [[ "${lines[8]}" = "locationId: $REGION" ]]
  [[ "${lines[9]}" = "servingStatus: SERVING" ]]
}

# #################################### #
#      Terraform destroy test          #
# #################################### #

@test "Terraform destroy" {
  skip
  run terraform destroy -force
  [ "$status" -eq 0 ]
  [[ "$output" =~ 11\ destroyed ]]
}
