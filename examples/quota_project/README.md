# Quota Project

This example illustrates how to use quota_manager submodule to override customer quotas.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| folder\_id | The ID of a folder to host this project. | `string` | `""` | no |
| org\_id | The organization ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The project ID in which to override quota |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
