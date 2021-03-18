# Budget Project

This example illustrates how to use quota_manager submodule to override customer quotas.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The GCP project you want to override the consumer quotas. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| quota\_overrides | The server-generated names of the quota override in the provided project. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
