# Simple project with GKE shared VPC

This illustrates how to create a project with a shared VPC from a host project that is GKE suitable.

As shown in this exmaple, GKE shared VPC is only enabled if the "container.googleapis.com" API is in the "activate_apis" variable list.

It will do the following:

- Create a project
- Give appropriate iam permissions to the API and GKE service accounts on the host vpc project

Expected variables:

- `org_id`
- `billing_account`
- `shared_vpc`

To specify a subnet use the "shared_vpc_subnets" variable, and list subnets like the following:

- ["projects/<my-project-id>/regions/<my-region>/subnetworks/<subnet-one-id>", "projects/<my-project-id>/regions/<my-region>/subnetworks/<subnet-two-id>"]

If no subnets are specified, all networks and subnets from the host project are shared.

More information about GKE with Shared VPC can be found here: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | billing account | `any` | n/a | yes |
| default\_network\_tier | Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers. | `string` | `""` | no |
| org\_id | organization id | `any` | n/a | yes |
| shared\_vpc | The ID of the host project which hosts the shared VPC | `any` | n/a | yes |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$PROJECT\_ID/regions/$REGION/subnetworks/$SUBNET\_ID) | `list(string)` | `[]` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
