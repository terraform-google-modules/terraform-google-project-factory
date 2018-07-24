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

  run terraform plan
  [ "$status" -eq 0 ]
  [[ "$output" =~ 14\ to\ add ]]
  [[ "$output" =~ 0\ to\ change ]]
  [[ "$output" =~ 0\ to\ destroy ]]
}

@test "Terraform apply" {

  run terraform apply -auto-approve
  [ "$status" -eq 0 ]
  [[ "$output" =~ 14\ added ]]
  [[ "$output" =~ 0\ changed ]]
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

@test "Test the compute api must be activated" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud services list
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" = *"compute.googleapis.com"* ]]
}

@test "Test that project has the shared vpc associated (host project)" {

  PROJECT_ID="$(terraform output project_info_example)"
  GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud compute shared-vpc get-host-project $PROJECT_ID --format="get(name)"
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" = "$SHARED_VPC" ]]
}

@test "Test project has the service account created" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud iam service-accounts list --format=list
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" = "   email: project-service-account@$PROJECT_ID.iam.gserviceaccount.com" ]]
}

@test "Test project has not the default service account" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud iam service-accounts list
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" =~ project-service-account@$PROJECT_ID.iam.gserviceaccount.com ]]
  [[ "${lines[2]}" = "" ]]
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
  [[ "${lines[1]}" = "usageExportLocation.reportNamePrefix: usage-$PROJECT_ID" ]]
}

@test "Test both service account and GSuite group has role:roles/compute.networkUser on host project (shared VPC)" {

  export PROJECT_ID="$(terraform output project_info_example)"
  export GROUP_EMAIL="$(terraform output group_email_example)"

  run gcloud projects get-iam-policy $SHARED_VPC --format=list[compact] --filter="bindings.role=roles/compute.networkUser AND bindings.members=group:$GROUP_EMAIL AND bindings.members=serviceAccount:project-service-account@$PROJECT_ID.iam.gserviceaccount.com"
  [ "$status" -eq 0 ]
  [[ "$output" = *"{u'role': u'roles/compute.networkUser', u'members': [u'group:$GROUP_EMAIL', u'serviceAccount:project-service-account@$PROJECT_ID.iam.gserviceaccount.com']}"* ]]
}

# #################################### #
#      Terraform destroy test          #
# #################################### #

@test "Terraform destroy" {

  run terraform destroy -force
  [ "$status" -eq 0 ]
  [[ "$output" =~ 14\ destroyed ]]
}
