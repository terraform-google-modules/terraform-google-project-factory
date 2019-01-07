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
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | n/a | yes |
| organization\_id | The organization id for the associated services | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created project |

[^]: (autogen_docs_end)