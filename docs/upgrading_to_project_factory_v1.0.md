# Upgrading to Project Factory v1.0

The v1.0 release of Project Factory is a backwards incompatible release and
features significant changes, specifically with how G Suite resources are
managed. A state migration script is provided to update your existing states
to minimize or eliminate resource re-creations.

Note that upgrading requires you to have Python 3.7 installed.

## Migration Instructions

This migration was performed with the following example configuration.

Note that the "project-factory" module does not require G Suite functionality,
while the "project-factory-gsuite" module does.

```hcl
/// @file main.tf

provider "google" {
  credentials = "${file(var.credentials_path)}"
}

provider "gsuite" {
  credentials             = "${file(var.credentials_path)}"
  impersonated_user_email = "${var.admin_email}"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member"
  ]
}

module "project-factory" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "v0.3.0"
  random_project_id = "true"
  name              = "pf-gsuite-migrate-simple"
  org_id            = "${var.org_id}"
  billing_account   = "${var.billing_account}"
  credentials_path  = "${var.credentials_path}"
}

module "project-factory-gsuite" {
  source             = "terraform-google-modules/project-factory/google"
  version            = "v0.3.0"
  random_project_id  = "true"
  name               = "pf-gsuite-migrate-group"
  org_id             = "${var.org_id}"
  billing_account    = "${var.billing_account}"
  credentials_path   = "${var.credentials_path}"
  create_group       = "true"
  group_name         = "${var.project_group_name}"
  api_sa_group       = "${var.api_sa_group}"
  shared_vpc         = "${var.shared_vpc}"
  shared_vpc_subnets = "${var.shared_vpc_subnets}"
}
```

### Update the project-factory source

Update the project-factory module source to the Project Factory v1.0.0 release.

Note that any projects which depend on G Suite features must be updated to point to the [gsuite-enabled submodule](../modules/gsuite_enabled).

```diff
diff --git i/main.tf w/main.tf
index d876954..ebb3b1e 100755
--- i/main.tf
+++ w/main.tf
@@ -14,7 +14,7 @@ provider "gsuite" {

 module "project-factory" {
   source            = "terraform-google-modules/project-factory/google"
-  version           = "v0.3.0"
+  version           = "v1.0.0"
   random_project_id = "true"
   name              = "pf-gsuite-migrate-simple"
   org_id            = "${var.org_id}"
@@ -24,8 +24,8 @@ module "project-factory" {

 module "project-factory-gsuite" {
-  source             = "terraform-google-modules/project-factory/google"
-  version            = "v0.3.0"
+  source             = "terraform-google-modules/project-factory/google//modules/gsuite_enabled"
+  version            = "v1.0.0"
   random_project_id  = "true"
   name               = "pf-gsuite-migrate-group"
   org_id             = "${var.org_id}"
```

Additionally, `org_id` is now required so you will need to add
it as an argument if you didn't already specify it on your projects.

### Download the state migration script

 ```
curl -O https://raw.githubusercontent.com/terraform-google-modules/terraform-google-project-factory/v1.0.0/helpers/migrate.py
chmod +x migrate.py
```

### Reinitialize Terraform

```
terraform init -upgrade
```

### Locally download your Terraform state

This step is only required if you are using [remote state](https://www.terraform.io/docs/state/remote.html).

```
terraform state pull >> terraform.tfstate
```

You should then disable remote state temporarily:

```hcl
# terraform {
#   backend "gcs" {
#     bucket  = "my-bucket-name"
#     prefix  = "terraform/state/projects"
#   }
# }
```

After commenting out your remote state configuration, you must re-initialize Terraform.

```
terraform init
```

### Migrate the Terraform state to match the new Project Factory module structure

```
./migrate.py terraform.tfstate terraform.tfstate.new
```

Expected output:
```txt
cp terraform.tfstate terraform.tfstate.new
---- Migrating the following project-factory modules:
-- module.project-factory
Moved module.project-factory.random_id.random_project_id_suffix to module.project-factory.module.project-factory.random_id.random_project_id_suffix
Moved module.project-factory.google_project.project to module.project-factory.module.project-factory.google_project.project
Moved module.project-factory.google_project_service.project_services to module.project-factory.module.project-factory.google_project_service.project_services
Moved module.project-factory.null_resource.delete_default_compute_service_account to module.project-factory.module.project-factory.null_resource.delete_default_compute_service_account
Moved module.project-factory.google_service_account.default_service_account to module.project-factory.module.project-factory.google_service_account.default_service_account
State migration complete, verify migration with `terraform plan -state 'terraform.tfstate.new'`
```

### Check that terraform plans for expected changes

```
terraform plan -state terraform.tfstate.new
```

The G Suite refactor adds an additional IAM membership and needs to re-create
two resources, due to how resources were split up between the `gsuite_enabled`
and `core_project_factory` modules. Depending on the version
you are upgrading from, it might also add a `null_resource` for `preconditions` checks.

```txt

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

random_id.random_project_id_suffix: Refreshing state... (ID: I9w)
google_project.project: Refreshing state... (ID: pf-gsuite-migrate-group-23dc)
data.google_organization.org: Refreshing state...
data.google_organization.org: Refreshing state...
gsuite_group.group: Refreshing state... (ID: 03oy7u293zvtv3v)
google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[1]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...up:pf-gsuite-migrate-group@phoogle.net)
google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[2]: Refreshing state... (ID: projects/thebo-host-c15e/regions/europe...up:pf-gsuite-migrate-group@phoogle.net)
google_compute_subnetwork_iam_member.group_role_to_vpc_subnets[0]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...up:pf-gsuite-migrate-group@phoogle.net)
data.google_compute_default_service_account.default: Refreshing state...
gsuite_group_member.api_s_account_api_sa_group_member: Refreshing state... (ID: 118009464384327601974)
google_service_account.default_service_account: Refreshing state... (ID: projects/pf-gsuite-migrate-group-23dc/s...ate-group-23dc.iam.gserviceaccount.com)
google_project_service.project_services: Refreshing state... (ID: pf-gsuite-migrate-group-23dc/compute.googleapis.com)
google_project_iam_member.gsuite_group_role: Refreshing state... (ID: pf-gsuite-migrate-group-23dc/roles/edit...up:pf-gsuite-migrate-group@phoogle.net)
google_service_account_iam_member.service_account_grant_to_group: Refreshing state... (ID: projects/pf-gsuite-migrate-group-23dc/s...up:pf-gsuite-migrate-group@phoogle.net)
google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...ate-group-23dc.iam.gserviceaccount.com)
google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...ate-group-23dc.iam.gserviceaccount.com)
google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2]: Refreshing state... (ID: projects/thebo-host-c15e/regions/europe...ate-group-23dc.iam.gserviceaccount.com)
google_project_iam_member.controlling_group_vpc_membership[2]: Refreshing state... (ID: thebo-host-c15e/roles/compute.networkUs...3246@cloudservices.gserviceaccount.com)
google_project_iam_member.controlling_group_vpc_membership[1]: Refreshing state... (ID: thebo-host-c15e/roles/compute.networkUs...up:pf-gsuite-migrate-group@phoogle.net)
google_project_iam_member.controlling_group_vpc_membership[0]: Refreshing state... (ID: thebo-host-c15e/roles/compute.networkUs...ate-group-23dc.iam.gserviceaccount.com)
google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2]: Refreshing state... (ID: projects/thebo-host-c15e/regions/europe...3246@cloudservices.gserviceaccount.com)
google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...3246@cloudservices.gserviceaccount.com)
google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1]: Refreshing state... (ID: projects/thebo-host-c15e/regions/us-wes...3246@cloudservices.gserviceaccount.com)
google_compute_shared_vpc_service_project.shared_vpc_attachment: Refreshing state... (ID: thebo-host-c15e/pf-gsuite-migrate-group-23dc)
null_resource.delete_default_compute_service_account: Refreshing state... (ID: 3094237059262702049)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

+ module.project-factory.google_project_iam_member.controlling_group_vpc_membership
      id:      <computed>
      etag:    <computed>
      member:  "group:pf-gsuite-migrate-group@phoogle.net"
      project: "thebo-host-c15e"
      role:    "roles/compute.networkUser"

-/+ module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1] (new resource required)
      id:      "thebo-host-c15e/roles/compute.networkUser/group:pf-gsuite-migrate-group@phoogle.net" => <computed> (forces new resource)
      etag:    "BwV9O377mQw=" => <computed>
      member:  "group:pf-gsuite-migrate-group@phoogle.net" => "serviceAccount:303471683246@cloudservices.gserviceaccount.com" (forces new resource)
      project: "thebo-host-c15e" => "thebo-host-c15e"
      role:    "roles/compute.networkUser" => "roles/compute.networkUser"

-/+ module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2] (new resource required)
      id:      "thebo-host-c15e/roles/compute.networkUser/serviceAccount:303471683246@cloudservices.gserviceaccount.com" => <computed> (forces new resource)
      etag:    "BwV9O377mQw=" => <computed>
      member:  "serviceAccount:303471683246@cloudservices.gserviceaccount.com" => "serviceAccount:project-service-account@pf-gsuite-migrate-group-23dc.iam.gserviceaccount.com" (forces new resource)
      project: "thebo-host-c15e" => "thebo-host-c15e"
      role:    "roles/compute.networkUser" => "roles/compute.networkUser"
Plan: 3 to add, 0 to change, 2 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Back up the old Terraform state and switch to the new Terraform state

If the Terraform plan suggests no changes or only the IAM changes above, replace the old state file with the new state file.

```
mv terraform.tfstate terraform.tfstate.pre-migrate
mv terraform.tfstate.new terraform.tfstate
```

### Run Terraform to reconcile any differences

```
terraform apply
```

### Re-enable remote state

You should then re-enable remote state:

```hcl
terraform {
  backend "gcs" {
    bucket  = "my-bucket-name"
    prefix  = "terraform/state/projects"
  }
}
```

After restoring remote state, you need to re-initialize Terraform and push your local state to the remote:

```
terraform init -force-copy
```

### Clean up

Once you are done with the migration, you can safely remove `migrate.py`.

```
rm migrate.py
```

If you are using remote state, you can also remove the local state copies.

```
rm -rf terraform.tfstate*
```

## Troubleshooting

### Errors about invalid arguments

You might get errors about invalid arguments, such as:

```
Error: module "project-pfactory-development": "sa_group" is not a valid argument
Error: module "project-pfactory-development": "api_sa_group" is not a valid argument
Error: module "project-pfactory-development": "create_group" is not a valid argument
```

These are related to projects which depend on G Suite functionality.
Make sure to update the source of such projects to point to the [G Suite module](../modules/gsuite_enabled)

### Missing `org_id`

If your existing configuration doesn't specify the `org_id`,
you might see some errors on upgrade:

```
Initializing the backend...

Error: module "project_factory": missing required argument "org_id"
```

The fix for this is to explicitly set the `org_id` argument
on your projects.

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
