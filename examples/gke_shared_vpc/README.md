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

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | billing account | string | - | yes |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |
| org\_id | organization id | string | - | yes |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | - | yes |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$PROJECT_ID/regions/$REGION/subnetworks/$SUBNET_ID) | list | `<list>` | no |

[^]: (autogen_docs_end)