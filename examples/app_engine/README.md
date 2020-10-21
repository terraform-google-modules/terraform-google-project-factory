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
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| folder\_id | The ID of a folder to host this project. | `string` | `""` | no |
| location\_id | The location to serve the app from. | `string` | `"us-east4"` | no |
| org\_id | The organization ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_name | Unique name of the app, usually apps/{PROJECT\_ID}. |
| default\_hostname | The default hostname for this app. |
| location\_id | The location app engine is serving from |
| project\_id | The project ID where app engine is created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
