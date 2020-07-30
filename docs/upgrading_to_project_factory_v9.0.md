# Upgrading to Project Factory v9.0

The v9.0 release of Project Factory is a backwards incompatible release for
service projects created with [shared_vpc](../modules/shared_vpc) module that
also have `container.googleapis.com` and/or `dataproc.googleapis.com` API's
enabled. If you don't have these API's enabled on your service projects or you
are creating new projects then there is no action required on your end.

## Migration Instructions

If your service projects have the `container.googleapis.com` API enabled then
follow instructions in [GKE API already enabled](#gke-api-already-enabled).

If your service projects have the `dataproc.googleapis.com` API enabled then
follow instructions in [Dataproc API already enabled](#dataproc-api-already-enabled).

### GKE API already enabled

If you have the `container.googleapis.com` API enabled you will see in your
terraform plan that `google_compute_subnetwork_iam_member`
and `google_compute_subnetwork_iam_member` resources will be recreated. This is
a safe operation and you can apply the changes. Example plan can look like this:
```diff
# module.example.module.service-project.module.project-factory.google_compute_subnetwork_iam_member.gke_shared_vpc_subnets[0] will be destroyed
  - resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
      - etag       = "BwWrwEtp6B4=" -> null
      - id         = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-01/roles/compute.networkUser/serviceaccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - member     = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - project    = "pf-ci-shared2-host-0004-29fd" -> null
      - region     = "us-west1" -> null
      - role       = "roles/compute.networkUser" -> null
      - subnetwork = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-01" -> null
    }

  # module.example.module.service-project.module.project-factory.google_compute_subnetwork_iam_member.gke_shared_vpc_subnets[1] will be destroyed
  - resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
      - etag       = "BwWrwEtrwLA=" -> null
      - id         = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-02/roles/compute.networkUser/serviceaccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - member     = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - project    = "pf-ci-shared2-host-0004-29fd" -> null
      - region     = "us-west1" -> null
      - role       = "roles/compute.networkUser" -> null
      - subnetwork = "projects/pf-ci-shared2-host-0004-29fd/regions/us-west1/subnetworks/shared-network-subnet-02" -> null
    }

  # module.example.module.service-project.module.project-factory.google_project_iam_member.gke_host_agent[0] will be destroyed
  - resource "google_project_iam_member" "gke_host_agent" {
      - etag    = "BwWrwEtQfSY=" -> null
      - id      = "pf-ci-shared2-host-0004-29fd/roles/container.hostServiceAgentUser/serviceaccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com" -> null
      - project = "pf-ci-shared2-host-0004-29fd" -> null
      - role    = "roles/container.hostServiceAgentUser" -> null
    }

  # module.example.module.service-project.module.shared_vpc_access.google_compute_subnetwork_iam_member.gke_shared_vpc_subnets[0] will be created
  + resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + member     = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com"
      + project    = "pf-ci-shared2-host-0004-29fd"
      + region     = "us-west1"
      + role       = "roles/compute.networkUser"
      + subnetwork = "shared-network-subnet-01"
    }

  # module.example.module.service-project.module.shared_vpc_access.google_compute_subnetwork_iam_member.gke_shared_vpc_subnets[1] will be created
  + resource "google_compute_subnetwork_iam_member" "gke_shared_vpc_subnets" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + member     = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com"
      + project    = "pf-ci-shared2-host-0004-29fd"
      + region     = "us-west1"
      + role       = "roles/compute.networkUser"
      + subnetwork = "shared-network-subnet-02"
    }

  # module.example.module.service-project.module.shared_vpc_access.google_project_iam_member.gke_host_agent[0] will be created
  + resource "google_project_iam_member" "gke_host_agent" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:service-740499050292@container-engine-robot.iam.gserviceaccount.com"
      + project = "pf-ci-shared2-host-0004-29fd"
      + role    = "roles/container.hostServiceAgentUser"
    }
```

### Dataproc API already enabled
If you have `dataproc.googleapis.com` API enabled on your projects then terraform
plan will try to bind `roles/compute.networkUser` to
`service-<PROJECT_NUMBER>@dataproc-accounts.iam.gserviceaccount.com` at the
project level. Example:
```diff
  # module.example.module.service-project.module.shared_vpc_access.google_project_iam_member.dataproc_shared_vpc_network_user[0] will be created
  + resource "google_project_iam_member" "dataproc_shared_vpc_network_user" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:service-740499050292@dataproc-accounts.iam.gserviceaccount.com"
      + project = "pf-ci-shared2-host-0004-29fd"
      + role    = "roles/compute.networkUser"
    }
```

If you have already binded the `roles/compute.networkUser` to
`service-<PROJECT_NUMBER>@dataproc-accounts.iam.gserviceaccount.com` at the
project level then please remove that binding before running `terraform apply`.
