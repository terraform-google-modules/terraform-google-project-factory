# Simple Project

This example illustrates how to create a simple project using the `fabric-project` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | Service APIs to enable. | `list(string)` | <pre>[<br>  "serviceusage.googleapis.com",<br>  "compute.googleapis.com"<br>]</pre> | no |
| billing\_account | Billing account id. | `string` | n/a | yes |
| name | Project name, joined with prefix. | `string` | `"fabric-project"` | no |
| owners | Optional list of IAM-format members to set as project owners. | `list(string)` | `[]` | no |
| parent | Organization or folder id, in the `organizations/nnn` or `folders/nnn` format. | `string` | n/a | yes |
| prefix | Prefix prepended to project name, uses random id by default. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the created project. |
| project\_id | The project id of the created project. |
| project\_number | The project number of the created project. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
