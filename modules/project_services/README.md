# Project API Activation

This optional module is used to enable project APIs in your project. The list of
APIs to be enabled is specified using the `activate_apis` variable.

This module uses the [`google_project_service`](https://www.terraform.io/docs/providers/google/r/google_project_service.html)
resource, which is  _non-authoritative_, as opposed to the [`google_project_services`](https://www.terraform.io/docs/providers/google/r/google_project_services.html)
resource, which is _authoritative_. Authoritative in this case means that services
that are not defined in the config will be removed, or disabled, in the project.
In practice, this is dangerous because it is fairly easy to inadventently disable
APIs without knowing it. Therefore, it is recommended to avoid using
[`google_project_services`], and to use [`google_project_service`] instead.


## Prerequisites

1. Service account used to run Terraform has permissions to manage project APIs:
[`roles/serviceusage.serviceUsageAdmin`](https://cloud.google.com/iam/docs/understanding-roles#service-usage-roles) or [`roles/owner`](https://cloud.google.com/iam/docs/understanding-roles#primitive_role_definitions)

## Example Usage
```
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "2.1.3"

  project_id                  = "my-project-id"

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}
```

See [examples/project_services](./examples/project_services) for a full example example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list(string) | n/a | yes |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_dependent_services | string | `"true"` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy | string | `"true"` | no |
| enable\_apis | Whether to actually enable the APIs. If false, this module is a no-op. | string | `"true"` | no |
| project\_id | The GCP project you want to enable APIs on | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The GCP project you want to enable APIs on |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
