# Simple Project

This example illustrates how to create a simple project.

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`
- `credentials_path`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | `string` | `""` | no |
| organization\_id | The organization id for the associated services | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
