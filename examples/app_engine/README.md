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
| admin\_email | Admin user email on Gsuite | string | - | yes |
| billing\_account | The ID of the billing account to associate this project with | string | - | yes |
| organization\_id | The organization id for the associated services | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_engine\_enabled\_example | Whether app engine is enabled |
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created project |

[^]: (autogen_docs_end)