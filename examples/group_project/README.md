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

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_email | Admin user email on Gsuite | string | - | yes |
| api\_sa\_group | An existing GSuite group email to place the Google APIs Service Account for the project in | string | - | yes |
| billing\_account | The ID of the billing account to associate this project with | string | - | yes |
| credentials\_file\_path | Service account json auth path | string | - | yes |
| organization\_id | The organization id for the associated services | string | - | yes |
| project\_group\_name | The name of a GSuite group to create for controlling the project | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| group\_email\_example | The email of the created GSuite group |
| project\_info\_example | The ID of the created project |

[^]: (autogen_docs_end)