# Project with tags

This example illustrates how to create a project with a tag binding.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| folder\_id | The ID of a folder to host this project. | `string` | `null` | no |
| organization\_id | The organization id for the associated services | `string` | `"684124036889"` | no |
| tag\_value | value | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The ID of the created project |
| project\_num | The number of the created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
