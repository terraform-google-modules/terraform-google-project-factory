# Budget Project

This example illustrates how to create a simple project with Budget alerts created.

It will do the following:
- Create a PubSub Topic
- Create a project
- Enable Budget creating on the project with PubSub forwarding

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| budget\_alert\_spent\_percents | The list of percentages of the budget to alert on | list(number) | `<list>` | no |
| budget\_amount | The amount to use for the budget | number | `"10"` | no |
| budget\_credit\_types\_treatment | Specifies how credits should be treated when determining spend for threshold calculations | string | `"EXCLUDE_ALL_CREDITS"` | no |
| budget\_services | A list of services to be included in the budget | list(string) | `<list>` | no |
| folder\_id | The ID of a folder to host this project. | string | `""` | no |
| location\_id | The location to serve the app from. | string | `"us-east4"` | no |
| org\_id | The organization ID. | string | n/a | yes |
| parent\_project\_id | The project_id of the parent project to add as an additional project for the budget | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| additional\_budget\_name | The name of the 2nd budget manually created |
| budget\_alert\_spent\_percents | The list of percentages of the budget to alert on |
| budget\_amount | The amount to use for the budget |
| budget\_credit\_types\_treatment | Specifies how credits should be treated when determining spend for threshold calculations |
| budget\_services | A list of services to be included in the budget |
| main\_budget\_name | The name of the budget created by the core project factory module |
| parent\_project\_id | The project_id of the parent project to add as an additional project for the budget |
| project\_id | The project ID created |
| pubsub\_topic | The PubSub topic name created for budget alerts |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
