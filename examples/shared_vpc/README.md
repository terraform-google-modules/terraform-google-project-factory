# Shared VPC Host Project

This example illustrates how to create a [Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc) host project.

It includes creating the host project and using the [network module](https://github.com/terraform-google-modules/terraform-google-network) to create network.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| folder\_id | The folder to create projects in | string | n/a | yes |
| host\_project\_name | Name for Shared VPC host project | string | `"shared-vpc-host"` | no |
| network\_name | Name for Shared VPC network | string | `"shared-network"` | no |
| organization\_id | The organization id for the associated services | string | n/a | yes |
| service\_project\_name | Name for Shared VPC service project | string | `"shared-vpc-service"` | no |

## Outputs

| Name | Description |
|------|-------------|
| host\_project | The full host project info |
| host\_project\_id | The ID of the created project |
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| service\_project | The service project info |
| vpc | The network info |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
