# Google Cloud Project Factory with G Suite Terraform Module

This module performs the same functions as the
[root module][root-module] with the addition of integrating G Suite.

## Usage

There are multiple examples included in the [examples] folder but simple usage is as follows:

```hcl
module "project-factory" {
  source = "terraform-google-modules/project-factory/google//modules/gsuite_enabled"
  version = "~> 10.1"

  billing_account   = "ABCDEF-ABCDEF-ABCDEF"
  create_group      = true
  group_name        = "test_sa_group"
  group_role        = "roles/editor"
  name              = "pf-test-1"
  org_id            = "1234567890"
  random_project_id = true
  sa_group          = "test_sa_group@yourdomain.com"
  shared_vpc        = "shared_vpc_host_name"

  shared_vpc_subnets = [
    "projects/base-project-196723/regions/us-east1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
  ]

  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
}
```

## Features

The G Suite Enabled module will perform the following actions in
addition to those of the root module:

1. Create a new Google group for the project using `group_name` if
   `create_group` is `true`.
1. Add the new default service account for the project to the
   `sa_group` in Google Groups, if specified.
1. Add the Google APIs service account to the `api_sa_group`,
   if specified.

The roles granted are specifically:

- New Default Service Account
  - MEMBER of the specified `sa_group`
- Google APIs Service Account
  - MEMBER of the specified `api_sa_group`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | The list of apis to activate within the project | `list(string)` | <pre>[<br>  "compute.googleapis.com"<br>]</pre> | no |
| api\_sa\_group | A G Suite group to place the Google APIs Service Account for the project in | `string` | `""` | no |
| auto\_create\_network | Create the default network | `bool` | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| bucket\_location | The location for a GCS bucket to create (optional) | `string` | `""` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket\_project project), useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket\_name) in, useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_versioning | Enable versioning for a GCS bucket to create (optional) | `bool` | `false` | no |
| budget\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| budget\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.7,<br>  1<br>]</pre> | no |
| budget\_amount | The amount to use for a budget alert | `number` | `null` | no |
| budget\_monitoring\_notification\_channels | A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed. | `list(string)` | `[]` | no |
| consumer\_quotas | The quotas configuration you want to override for the project. | <pre>list(object({<br>    service    = string,<br>    metric     = string,<br>    dimensions = any,<br>    limit      = string,<br>    value      = string,<br>  }))</pre> | `[]` | no |
| create\_group | Whether to create the group or not | `bool` | `false` | no |
| create\_project\_sa | Whether the default service account for the project shall be created | `bool` | `true` | no |
| default\_network\_tier | Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers. | `string` | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | `string` | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | `bool` | `true` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | `bool` | `true` | no |
| domain | The domain name (optional). | `string` | `""` | no |
| enable\_shared\_vpc\_host\_project | If this project is a shared VPC host project. If true, you must *not* set shared\_vpc variable. Default is false. | `bool` | `false` | no |
| enable\_shared\_vpc\_service\_project | If shared VPC should be used | `bool` | `false` | no |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| group\_name | A group to control the project by being assigned group\_role - defaults to ${project\_name}-editors | `string` | `""` | no |
| group\_role | The role to give the controlling group (group\_name) over the project (defaults to project editor) | `string` | `"roles/editor"` | no |
| labels | Map of labels for project | `map(string)` | `{}` | no |
| lien | Add a lien on the project to prevent accidental deletion | `bool` | `false` | no |
| name | The name for the project | `any` | n/a | yes |
| org\_id | The organization ID. | `any` | n/a | yes |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | `string` | `""` | no |
| project\_sa\_name | Default service account name for the project. | `string` | `"project-service-account"` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id` | `bool` | `false` | no |
| sa\_group | A G Suite group to place the default Service Account for the project in | `string` | `""` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | `string` | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | `string` | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project\_id/regions/$region/subnetworks/$subnet\_id) | `list(string)` | `[]` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain | The organization's domain |
| group\_email | The email of the created G Suite group with group\_name |
| group\_name | The group\_name of the G Suite group |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | n/a |
| project\_name | n/a |
| project\_number | n/a |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

[examples]: ../../examples/
[root-module]: ../../README.md
