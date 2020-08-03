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
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | billing account | string | n/a | yes |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | n/a | yes |
| org\_id | organization id | string | n/a | yes |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | n/a | yes |
| shared\_vpc\_subnets | Map of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) and list of allowed API's. Example: projects/$project_id/regions/$region/subnetworks/$subnet_id = [] or projects/$project_id/regions/$region/subnetworks/$subnet_id = ["gke"]. Valid values for API list are: "", "gke", and "dataproc" | map(list(string)) | `<map>` | no |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
