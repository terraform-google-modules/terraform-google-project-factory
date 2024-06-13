# App Engine

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
| auth\_domain | The domain to authenticate users with when using App Engine's User API. | `string` | `""` | no |
| feature\_settings | A list of maps of optional settings to configure specific App Engine features. | `list(object({ split_health_checks = bool }))` | <pre>[<br>  {<br>    "split_health_checks": true<br>  }<br>]</pre> | no |
| location\_id | The location to serve the app from. | `string` | `""` | no |
| project\_id | The project to enable app engine on. | `string` | n/a | yes |
| serving\_status | The serving status of the app. | `string` | `"SERVING"` | no |

## Outputs

| Name | Description |
|------|-------------|
| code\_bucket | The GCS bucket code is being stored in for this app. |
| default\_bucket | The GCS bucket content is being stored in for this app. |
| default\_hostname | The default hostname for this app. |
| location\_id | The location app engine is serving from |
| name | Unique name of the app, usually apps/{PROJECT\_ID}. |
| url\_dispatch\_rule | A list of dispatch rule blocks. Each block has a domain, path, and service field. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
