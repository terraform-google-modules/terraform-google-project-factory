# Shared VPC Access

This module grants IAM permissions on host project and subnets to appropriate API service accounts based on activated
APIs. For now only GKE and Dataproc APIs are supported.

## Example Usage
```hcl
module "shared_vpc_access" {
  source              = "terraform-google-modules/project-factory/google//modules/shared_vpc_access"
  host_project_id     = var.shared_vpc
  service_project_id  = var.service_project
  active_apis         = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataproc.googleapis.com",
  ]
  shared_vpc_subnets  = [
    "projects/pf-ci-shared2/regions/us-west1/subnetworks/shared-network-subnet-01",
    "projects/pf-ci-shared2/regions/us-west1/subnetworks/shared-network-subnet-02",
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| active\_apis | The list of active apis on the service project. If api is not active this module will not try to activate it | list(string) | `<list>` | no |
| host\_project\_id | The ID of the host project which hosts the shared VPC | string | n/a | yes |
| service\_project\_id | The ID of the service project | string | n/a | yes |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list(string) | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| active\_api\_service\_accounts | List of active API service accounts in the service project. |
| project\_id | Service project ID. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
