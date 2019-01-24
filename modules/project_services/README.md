# project_services

This optional module is used to enable project APIs in your project. By default,
this module will enable the following APIs:
- `compute.googleapis.com`
- `iam.googleapis.com`

The list of APIs to be enabled can be customized with the `activate_apis`
variable.

Google Project Factory already does this [here](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/modules/core_project_factory/main.tf#L112), but this module allows you to enable APIs on projects that were not created with Project Factory.

## Prerequisites

1. Service account used to run Terraform has permissions to manage project APIs: 
[`roles/serviceusage.serviceUsageAdmin`](https://cloud.google.com/iam/docs/understanding-roles#service-usage-roles) or `Owner`

## Usage

```
terraform plan -var='project_id=<YOUR PROJECT ID>' -out=tfplan
terraform apply tfplan
```

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list | `<list>` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy | string | `"true"` | no |
| enable\_apis | Whether to actually enable the APIs. If false, this module is a no-op. | string | `"true"` | no |
| project\_id | The GCP project you want to enable APIs on | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The GCP project you want to enable APIs on |

[^]: (autogen_docs_end)