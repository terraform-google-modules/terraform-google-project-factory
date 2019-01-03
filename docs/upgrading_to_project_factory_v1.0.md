# Upgrading to Project Factory v1.0

The v1.0 release of Project Factory is a backwards incompatible release and
features significant changes, specifically with how G Suite resources are
managed. A state migration script is provided to update your existing states
to minimize or eliminate resource re-creations.

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

### 1. Update the project-factory source

Update the project-factory module source to the Project Factory v1.0.0 release:
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
@@ -24,7 +24,7 @@ module "project-factory" {
 
 module "project-factory-gsuite" {
   source             = "terraform-google-modules/project-factory/google"
-  version            = "v0.3.0"
+  version            = "v1.0.0"
   random_project_id  = "true"
   name               = "pf-gsuite-migrate-group"
   org_id             = "${var.org_id}"
```

### 2.  Reinitialize Terraform

```
terraform init -upgrade
```

### 3. Download the state migration script

```
curl -O https://raw.githubusercontent.com/terraform-google-modules/terraform-google-project-factory/v1.0.0/helpers/migrate.py
chmod +x migrate.py
```

#### 4. Migrate the Terraform state to match the new Project Factory module structure

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

#### 5. Check that terraform does not detect changes

```
terraform plan -state terraform.tfstate.new
```

Expected output:
```txt
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

random_id.random_project_id_suffix: Refreshing state... (ID: l3A)
google_project.project: Refreshing state... (ID: pf-gsuite-migrate-simple-9770)
data.google_organization.org: Refreshing state...
google_service_account.default_service_account: Refreshing state... (ID: projects/pf-gsuite-migrate-simple-9770/...te-simple-9770.iam.gserviceaccount.com)
google_project_service.project_services: Refreshing state... (ID: pf-gsuite-migrate-simple-9770/compute.googleapis.com)
data.google_compute_default_service_account.default: Refreshing state...
null_resource.delete_default_compute_service_account: Refreshing state... (ID: 4378457466829456087)

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

#### 6. Back up the old Terraform state and switch to the new Terraform state

If the Terraform plan suggests no changes, replace the old state file with the new state file.

```
mv terraform.tfstate terraform.tfstate.pre-migrate
mv terraform.tfstate.new terraform.tfstate
```

### With GSuite Integration

This migration was performed with the following example configuration.
```hcl
/// @file group_project/main.tf
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

#### 1. Update the project-factory source and re-initialize Terraform

Update the project-factory module source to the v1.0.0 release and the gsuite_enabled module:

```diff
diff --git i/group_project/main.tf w/group_project/main.tf
index 7f8c3d0..e026b19 100755
--- i/group_project/main.tf
+++ w/group_project/main.tf
@@ -32,8 +32,8 @@ provider "gsuite" {
 }

 module "project-factory" {
-  source             = "terraform-google-modules/project-factory/google"
-  version            = "v0.3.0"
+  source             = "terraform-google-modules/project-factory/google//modules/gsuite_enabled"
+  version            = "v1.0.0"
   random_project_id  = "true"
   name               = "pf-gsuite-migrate-group"
   org_id             = "${var.org_id}"
```

#### 2.  Reinitialize Terraform

```
terraform init -upgrade
```

#### 3. Download the state migration script

```
curl -O https://raw.githubusercontent.com/terraform-google-modules/terraform-google-project-factory/v1.0.0/helpers/migrate.py
chmod +x migrate.py
```

#### 4. Migrate the Terraform state to match the new Project Factory module structure

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
Moved module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment to module.project-factory.module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment
Moved module.project-factory.null_resource.delete_default_compute_service_account to module.project-factory.module.project-factory.null_resource.delete_default_compute_service_account
Moved module.project-factory.google_service_account.default_service_account to module.project-factory.module.project-factory.google_service_account.default_service_account
Moved module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0] to module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]
Moved module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1] to module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]
Moved module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2] to module.project-factory.module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]
Moved module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[0]
Moved module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[1]
Moved module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.service_account_role_to_vpc_subnets[2]
Moved module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[0]
Moved module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[1]
Moved module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2] to module.project-factory.module.project-factory.google_compute_subnetwork_iam_member.apis_service_account_role_to_vpc_subnets[2]
```

#### 5. Check that terraform plans for expected changes

```
terraform plan -state terraform.tfstate.new
```

The GSuite refactor adds an additional IAM membership and needs to re-create
two resources, due to how resources were split up between the `gsuite_enabled`
and `core_project_factory` modules.

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

#### 6. Back up the old Terraform state and switch to the new Terraform state

If `terraform plan` suggests the above changes, replace the old state file with the new state file.

```
mv terraform.tfstate terraform.tfstate.pre-migrate
mv terraform.tfstate.new terraform.tfstate
```

#### 7. Run Terraform to reconcile any differences

```
terraform apply
```
