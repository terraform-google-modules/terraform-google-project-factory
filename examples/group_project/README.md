# Group Project

This example illustrates how to create a group project.

It will do the following:
- Create a project
- Create a Gsuite group
- Give members of the newly created Gsuite group the appropriate access on the project
- Make APIs service account member of api_sa_group in Gsuite

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`
- `api_sa_group`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_email | Admin user email on Gsuite. This should be a user account, not a service account. | `any` | n/a | yes |
| api\_sa\_group | An existing G Suite group email to place the Google APIs Service Account for the project in | `any` | n/a | yes |
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| organization\_id | The organization id for the associated services | `any` | n/a | yes |
| project\_group\_name | The name of a G Suite group to create for controlling the project | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| group\_email\_example | The email of the created G Suite group |
| project\_info\_example | The ID of the created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
