# Simple Project

This example illustrates how to create a simple project.

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`
- `credentials_path`

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_email | Admin user email on Gsuite | string | - | yes |
| billing\_account | - | string | - | yes |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |
| organization\_id | - | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created project |

[^]: (autogen_docs_end)