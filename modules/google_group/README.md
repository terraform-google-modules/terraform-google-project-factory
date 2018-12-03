# google_group

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain | The domain name (optional if `email` is passed) | string | `` | no |
| email | The email used for the group, this is automatically created | string | `` | no |
| name | A group to control the project by being assigned group_role - defaults to ${project_name}-editors | string | `` | no |
| project\_name | The name of the project in which the group will exist | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| email | The email of the group |
| id | The identity of the group, in the format 'group:{email ID}' |
| name | The name of the group |

[^]: (autogen_docs_end)