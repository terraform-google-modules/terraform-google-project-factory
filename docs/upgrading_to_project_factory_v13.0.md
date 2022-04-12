# Upgrading to Project Factory v13.0

The v13.0 release of Project Factory is a backwards incompatible release.

## Migration Instructions

### `grant_services_network_role` renamed to `grant_network_role`

Variable `grant_services_network_role` is renamed to `grant_network_role` to provide the ability to not manage networkUser role through project factory module v13.0

```diff
 module "project-factory" {
   source  = "terraform-google-modules/project-factory/google"
-  version = "~> 12.0"
+  version = "~> 13.0"

   name                            = "pf-test-1"
   random_project_id               = "true"
   org_id                          = "1234567890"
   usage_bucket_name               = "pf-test-1-usage-report-bucket"
   usage_bucket_prefix             = "pf/test/1/integration"
   billing_account                 = "ABCDEF-ABCDEF-ABCDEF"
-  grant_services_network_role     = "..."
+  grant_network_role              = "..."
 }
```

Service accounts principles on which networkUser can be managed through `grant_network_role` variable.
- Project default service account
- [Google APIs service agent](https://cloud.google.com/compute/docs/access/service-accounts#google_apis_service_agent)
- group_email
- dataflow, dataproc, composer, container, and vpcaccess API [agent accounts](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/616ede9456cc8f86ef7995192af3473d17ee7946/modules/shared_vpc_access/main.tf#L24-L30).

Additional roles that are managed through `grant_network_role` variable.
- roles/container.hostServiceAgentUser on "serviceAccount:service-{PROJECT-NUMBER}@container-engine-robot.iam.gserviceaccount.com
- roles/composer.sharedVpcAgent on "service-{PROJECT-NUMBER}@cloudcomposer-accounts.iam.gserviceaccount.com"

### Add `dimensions` field to `consumer_quota` object

The `dimensions` field was added to the `consumer_quota` object.

```diff
 module "project-factory" {
   source  = "terraform-google-modules/project-factory/google"
-  version = "~> 12.0"
+  version = "~> 13.0"

  name                = "pf-test-1"
  random_project_id   = "true"
  org_id              = "1234567890"
  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
  billing_account     = "ABCDEF-ABCDEF-ABCDEF"
  consumer_quotas = [
    {
      service    = "servicemanagement.googleapis.com"
      metric     = urlencode("servicemanagement.googleapis.com/default_requests")
      limit      = urlencode("/min/project")
+     dimensions = {}
      value      = "95"
    }
  ]
}
```

### Google Cloud Platform Provider upgrade

The Project Factory module now requires version 4.11 or higher of the Google Cloud Platform Provider and 4.11 or higher of
the Google Cloud Platform Beta Provider.
