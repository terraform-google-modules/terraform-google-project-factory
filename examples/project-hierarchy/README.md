# Project Hierarchy

This is example illustrates how to set up a project hierarchy.

It will do the following:
- Create a folder on an organization
- Create two projects under the newly created folder

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`
- `credentials_path`

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin_email | Admin user email on Gsuite | string | - | yes |
| billing_account | The ID of the billing account to associate this project with | string | - | yes |
| organization_id | The organization id for the associated services | string | - | yes |
| credentials_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain_example | The organization's domain |
| project_info_example | The ID of the created prod_gke project |
| project_info_factory_example | The ID of the created factory project |

[^]: (autogen_docs_end)
