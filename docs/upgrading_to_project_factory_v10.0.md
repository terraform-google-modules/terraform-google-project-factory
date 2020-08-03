# Upgrading to Project Factory v10.0

The v10.0 release of Project Factory is a backwards incompatible release for
service projects that have `shared_vpc_subnets` set. The variable type of
`shared_vpc_subnets` has changed from `list(string)` to `map(list(string))`.
In the previous versions all subnets listed in `shared_vpc_subnets` would be
set with GKE or Dataproc permissions if these API's are enabled. Starting from
version 10.0 you can specify which subnets are set for gke or dataproc.

## Migration Instructions

If you have `shared_vpc_subnets` set in your module you will have to change it
to be a map
```diff
 diff --git a/examples/shared_vpc/main.tf b/examples/shared_vpc/main.tf
index eb31a6b..95a85fd 100644
--- a/examples/shared_vpc/main.tf
+++ b/examples/shared_vpc/main.tf
@@ -114,8 +114,11 @@ module "service-project" {
   billing_account    = var.billing_account
   shared_vpc_enabled = true

-  shared_vpc         = module.vpc.project_id
-  shared_vpc_subnets = module.vpc.subnets_self_links
+  shared_vpc = module.vpc.project_id
+  shared_vpc_subnets = {
+    "${module.vpc.subnets_self_links[0]}" = ["gke"]
+    "${module.vpc.subnets_self_links[1]}" = ["dataproc"]
+    "${module.vpc.subnets_self_links[1]}" = []
+  }
```

Once you run `teraform plan` you will notices change in IAM permissions for
sunets. It can look something like this:
```
  # module.example.module.service-project.module.shared_vpc_access.google_compute_subnetwork_iam_member.dataproc_shared_vpc_subnets[0] will be created
  + resource "google_compute_subnetwork_iam_member" "dataproc_shared_vpc_subnets" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + member     = "serviceAccount:service-740499050292@dataproc-accounts.iam.gserviceaccount.com"
      + project    = "pf-ci-shared2-host-0004-29fd"
      + region     = "us-west1"
      + role       = "roles/compute.networkUser"
      + subnetwork = "shared-network-subnet-02"
    }

  # module.example.module.service-project.module.shared_vpc_access.google_compute_subnetwork_iam_member.gke_shared_vpc_subnets[1] will be destroyed
  - resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
      - etag       = "BwWrwRqi1lc=" -> null
      - id         = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-02/roles/compute.networkUser/serviceaccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - member     = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - project    = "pf-ci-shared2-host-0004-29fd" -> null
      - region     = "us-west1" -> null
      - role       = "roles/compute.networkUser" -> null
      - subnetwork = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-02" -> null
    }
```
In this case it is safe to run `terraform apply`.
