# Project Services

This example illustrates how to use the project_services submodule to activate APIs

Expected variables:
- `credentials_path`
- `project_id`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | string | `""` | no |
| project\_id | The GCP project you want to enable APIs on | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The GCP project you want to enable APIs on |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
