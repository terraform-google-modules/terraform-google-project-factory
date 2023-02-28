# Shared VPC Access

This module grants IAM permissions on host project and subnets to appropriate API service accounts based on activated
APIs. For now only GKE, Dataproc, Dataflow, Composer and Serverless VPC Access APIs are supported.

## Example Usage
```hcl
module "shared_vpc_access" {
  source              = "terraform-google-modules/project-factory/google//modules/shared_vpc_access"
  host_project_id     = var.shared_vpc
  service_project_id  = var.service_project
  active_apis         = [
    "container.googleapis.com",
    "dataproc.googleapis.com",
    "dataflow.googleapis.com",
    "datastream.googleapis.com",
    "composer.googleapis.com",
    "vpcaccess.googleapis.com",
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
|------|-------------|------|---------|:--------:|
| active\_apis | The list of active apis on the service project. If api is not active this module will not try to activate it | `list(string)` | `[]` | no |
| enable\_shared\_vpc\_service\_project | Flag set if SVPC enabled | `bool` | n/a | yes |
| grant\_network\_role | Whether or not to grant service agents the network roles on the host project | `bool` | `true` | no |
| grant\_services\_network\_admin\_role | Whether or not to grant Datastream Service acount the Network Admin role on the host project so it can manage firewall rules | `bool` | `false` | no |
| grant\_services\_security\_admin\_role | Whether or not to grant Kubernetes Engine Service Agent the Security Admin role on the host project so it can manage firewall rules | `bool` | `false` | no |
| host\_project\_id | The ID of the host project which hosts the shared VPC | `string` | n/a | yes |
| lookup\_project\_numbers | Whether to look up the project numbers from data sources. If false, `service_project_number` will be used instead. | `bool` | `true` | no |
| service\_project\_id | The ID of the service project | `string` | n/a | yes |
| service\_project\_number | Project number of the service project. Will be used if `lookup_service_project_number` is false. | `string` | `null` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project\_id/regions/$region/subnetworks/$subnet\_id) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| active\_api\_service\_accounts | List of active API service accounts in the service project. |
| project\_id | Service project ID. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
