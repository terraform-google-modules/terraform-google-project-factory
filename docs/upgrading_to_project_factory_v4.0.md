# Upgrading to Project Factory v4.0

The v4.0 release of Project Factory is a backwards incompatible release and
features minor changes, specifically with how Google Project Services (APIs)
are managed. A state migration script is provided to update your existing states
to minimize or eliminate resource re-creations.

Note that upgrading requires you to have Python 3.7 installed.

## Migration Instructions

This migration was performed with the following example configuration.

```hcl
/// @file main.tf

provider "google" {
  credentials = "${file(var.credentials_path)}"
}

module "my-project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "v3.0.0"
  random_project_id = "true"
  name              = "pf-project-services-migrate"
  org_id            = "${var.org_id}"
  billing_account   = "${var.billing_account}"
  credentials_path  = "${var.credentials_path}"
  activate_apis = [
    "compute.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
}
```

### Update the project-factory source

Update the project-factory module source to the Project Factory v4.0.0 release.

```diff
diff --git i/main.tf w/main.tf
index d876954..ebb3b1e 100755
--- i/main.tf
+++ w/main.tf
@@ -5,7 +5,7 @@ provider "google" {

 module "my-project" {
   source            = "terraform-google-modules/project-factory/google"
-  version           = "v3.0.0"
+  version           = "v4.0.0"
   random_project_id = "true"
   name              = "pf-project-services-migrate"
   org_id            = "${var.org_id}"
```

### Download the state migration script

 ```
curl -O https://raw.githubusercontent.com/terraform-google-modules/terraform-google-project-factory/v4.0.0/helpers/migrate4.py
chmod +x migrate4.py
```

### Reinitialize Terraform

```
terraform init -upgrade
```

### Backup your remote Terraform state

This step is only required if you are using [remote state](https://www.terraform.io/docs/state/remote.html).

```
terraform state pull > terraform-backup.tfstate
```

### Migrate the Terraform state to match the new Project Factory module structure

```
./migrate4.py
```

Expected output:
```txt
---- Migrating the following project-factory modules:
-- module.my-project.module.project-factory
Removed module.my-project.module.project-factory.google_project_service.project_services[0]
Successfully removed 1 resource instance(s).
module.my-project.module.project-factory.module.project_services.google_project_service.project_services["storage-api.googleapis.com"]: Importing from ID "pf-project-services-migrate/compute.googleapis.com"...
module.my-project.module.project-factory.module.project_services.google_project_service.project_services["storage-api.googleapis.com"]: Import prepared!
  Prepared google_project_service for import
module.my-project.module.project-factory.module.project_services.google_project_service.project_services["storage-api.googleapis.com"]: Refreshing state... [id=pf-project-services-migrate/compute.googleapis.com]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
State migration complete, verify migration with `terraform plan`
```

### Check that terraform plans for expected changes

```
terraform plan
```

The project services refactor will show this for each service:

```
# module.my-project.module.project-factory.module.project_services.google_project_service.project_services["compute.googleapis.com"] will be updated in-place
~ resource "google_project_service" "project_services" {
    + disable_dependent_services = true
    + disable_on_destroy         = true
      id                         = "pf-project-services-migrate/compute.googleapis.com"
      project                    = "pf-project-services-migrate"
      service                    = "compute.googleapis.com"

      timeouts {}
  }
```

### Run Terraform to reconcile any differences

```
terraform apply
```

### Clean up

Once you are done with the migration, you can safely remove `migrate.py`.

```
rm migrate4.py
```

If you are using remote state, you can also remove the local state backup.

```
rm -rf terraform-backup.tfstate
```

## Troubleshooting

### The migration script fails to run

If you get an error like this when running the migration script, it means you need upgrade
your Python version to 3.7.

```
Traceback (most recent call last):
  File "./migrate.py", line 372, in <module>
    main(sys.argv)
  File "./migrate.py", line 353, in main
    migrate(args.newstate, dryrun=args.dryrun)
  File "./migrate.py", line 314, in migrate
    for path in read_state(statefile)
  File "./migrate.py", line 282, in read_state
    encoding='utf-8')
  File "/usr/local/Cellar/python3/3.6.3/Frameworks/Python.framework/Versions/3.6/lib/python3.6/subprocess.py", line 403, in run
    with Popen(*popenargs, **kwargs) as process:
TypeError: __init__() got an unexpected keyword argument 'capture_output'
```
