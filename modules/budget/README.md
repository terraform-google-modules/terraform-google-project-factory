# Budget configuration for a project

This module allows the creation of a [google billing budget](https://www.terraform.io/docs/providers/google/r/billing_budget.html) tied to a specific `project_id`

## Usage

Basic usage of this module is as follows:

```hcl
module "project_myproject" {
  source          = "terraform-google-modules/project-factory/google//modules/budget"
  billing_account = "ABCD-1234-ABCD-1234"
  projects        = ["my-project-id"]
  amount          = "100"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| alert\_spend\_basis | The type of basis used to determine if spend has passed the threshold | `string` | `"CURRENT_SPEND"` | no |
| alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.7,<br>  1<br>]</pre> | no |
| amount | The amount to use as the budget | `number` | n/a | yes |
| billing\_account | ID of the billing account to set a budget on | `string` | n/a | yes |
| calendar\_period | Specifies the calendar period for the budget. Possible values are MONTH, QUARTER, YEAR, CALENDAR\_PERIOD\_UNSPECIFIED, CUSTOM. custom\_period\_start\_date and custom\_period\_end\_date must be set if CUSTOM | `string` | `null` | no |
| create\_budget | If the budget should be created | `bool` | `true` | no |
| credit\_types\_treatment | Specifies how credits should be treated when determining spend for threshold calculations | `string` | `"INCLUDE_ALL_CREDITS"` | no |
| custom\_period\_end\_date | Specifies the end date (DD-MM-YYYY) for the calendar\_period CUSTOM | `string` | `null` | no |
| custom\_period\_start\_date | Specifies the start date (DD-MM-YYYY) for the calendar\_period CUSTOM | `string` | `null` | no |
| display\_name | The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` | `string` | `null` | no |
| labels | A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget. | `map(string)` | `{}` | no |
| monitoring\_notification\_channels | A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed. | `list(string)` | `[]` | no |
| projects | The project ids to include in this budget. If empty budget will include all projects | `list(string)` | n/a | yes |
| services | A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/ | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | Resource name of the budget. Values are of the form `billingAccounts/{billingAccountId}/budgets/{budgetId}.` |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
