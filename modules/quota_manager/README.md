# Consumer quota override for a project

This module allows to manage the consumer override of quotas of a [google service usage consumer quota override](https://www.terraform.io/docs/providers/google/r/service_usage_consumer_quota_override.html) tied to a specific `project_id`

## Usage

Basic usage of this module is as follows:

```hcl
module "project_quota_manager" {
  source          = "terraform-google-modules/project-factory/google//modules/quota_manager"
  project         = "my-project-id"
  consumer_quotas = [
    {
        service        = "compute.googleapis.com"
        metric         = "SimulateMaintenanceEventGroup"
        limit          = "%2F100s%2Fproject"
        value = "19"
    },{
        service        = "servicemanagement.googleapis.com"
        metric         = "servicemanagement.googleapis.com%2Fdefault_requests"
        limit          = "%2Fmin%2Fproject"
        value = "95"
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| consumer\_quotas | The quotas configuration you want to override for the project. | <pre>list(object({<br>    service = string,<br>    metric  = string,<br>    limit   = string,<br>    value   = string,<br>  }))</pre> | n/a | yes |
| project\_id | The GCP project where you want to manage the consumer quotas | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| quota\_overrides | The server-generated names of the quota override. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
