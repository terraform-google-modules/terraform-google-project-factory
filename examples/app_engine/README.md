# App Engine Project

This example illustrates how to create a simple project with App Engine enabled.

It will do the following:
- Create a project
- Active the Google App Engine Admin API on the new project
- Create a new App Engine app

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin_email | Admin user email on Gsuite | string | - | yes |
| billing_account | The ID of the billing account to associate this project with | string | - | yes |
| organization_id | The organization id for the associated services | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| app_engine_enabled_example | Whether app engine is enabled |
| domain_example | The organization's domain |
| project_info_example | The ID of the created project |

[^]: (autogen_docs_end)
