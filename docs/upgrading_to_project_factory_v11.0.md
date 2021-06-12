# Upgrading to Project Factory v11.0

The v11.0 release of Project Factory is a backwards incompatible release.

## Migration Instructions

### Unused variables have been removed

Variables `credentials_path` and `impersonate_service_account` have been removed as we have removed the need for gcloud and local-execs in [v10.0](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/docs/upgrading_to_project_factory_v10.0.md). This change should be no-op.

```diff
 module "project-factory" {
   source  = "terraform-google-modules/project-factory/google"
-  version = "~> 10.0"
+  version = "~> 11.0"

   name                            = "pf-test-1"
   random_project_id               = "true"
   org_id                          = "1234567890"
   usage_bucket_name               = "pf-test-1-usage-report-bucket"
   usage_bucket_prefix             = "pf/test/1/integration"
   billing_account                 = "ABCDEF-ABCDEF-ABCDEF"
-  credentials_path                = "..."
-  impersonate_service_account     = "..."
 }
```

### Uniform Bucket Level Access is enabled by default

Uniform Bucket Level Access is enabled by default and controlled by the `bucket_ula` variable.

If you want to keep Uniform Bucket Level Access disabled, this variable should be set to false.
