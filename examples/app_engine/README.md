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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| auth\_domain | The domain to authenticate users with when using App Engine's User API. | string | n/a | yes |
| feature\_settings | A list of maps of optional settings to configure specific App Engine features. | list | `<list>` | no |
| location\_id | The location to serve the app from. | string | `"us-central"` | no |
| project\_id | The project to enable app engine on. | string | n/a | yes |
| serving\_status | The serving status of the app. | string | `"SERVING"` | no |

## Outputs

| Name | Description |
|------|-------------|
| code\_bucket | The GCS bucket code is being stored in for this app. |
| name | Unique name of the app, usually apps/{PROJECT_ID}. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
