export TF_VAR_billing_account="000000-000000-000000"
export TF_VAR_shared_vpc=""
export TF_VAR_sa_group=""
export TF_VAR_sa_role=""
export TF_VAR_usage_bucket_name=""
export TF_VAR_usage_bucket_prefix=""
export TF_VAR_gsuite_admin_account="user@example.com"
export TF_VAR_credentials_path="credentials.json"
export TF_VAR_activate_apis='["container.googleapis.com", "compute.googleapis.com"]'

## These values you can potentially leave at the defaults
export TF_VAR_name="$USER-pf-test-integration"
export TF_VAR_random_project_id="true"
export TF_VAR_create_group="false"
export TF_VAR_group_name="test_sa_group"
export TF_VAR_folder_id=""
export TF_VAR_org_id="000000000000"
export TF_VAR_group_role="roles/viewer"
export TF_VAR_region="us-east4"

export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="$TF_VAR_credentials_path"
