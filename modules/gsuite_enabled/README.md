# Google Cloud Project Factory with G Suite Terraform Module

This module performs the same functions as the
[root module][root-module] with the addition of integrating G Suite.

## Usage

There are multiple examples included in the [examples] folder but simple usage is as follows:

```hcl
module "project-factory" {
  source = "terraform-google-modules/project-factory/google//modules/gsuite_enabled"
  version = "~> 1.0"

  billing_account   = "ABCDEF-ABCDEF-ABCDEF"
  create_group      = "true"
  credentials_path  = "${local.credentials_file_path}"
  group_name        = "test_sa_group"
  group_role        = "roles/editor"
  name              = "pf-test-1"
  org_id            = "1234567890"
  random_project_id = "true"
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
   `create_group` is `"true"`.
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
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list(string) | `<list>` | no |
| api\_sa\_group | A G Suite group to place the Google APIs Service Account for the project in | string | `""` | no |
| auto\_create\_network | Create the default network | string | `"false"` | no |
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| bucket\_location | The location for a GCS bucket to create (optional) | string | `""` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `""` | no |
| bucket\_versioning | Enable versioning for a GCS bucket to create (optional) | bool | `"false"` | no |
| budget\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | string | `"null"` | no |
| budget\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | list(number) | `<list>` | no |
| budget\_amount | The amount to use for a budget alert | number | `"null"` | no |
| create\_group | Whether to create the group or not | bool | `"false"` | no |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | string | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | string | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | string | `"true"` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | string | `"true"` | no |
| domain | The domain name (optional). | string | `""` | no |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| group\_name | A group to control the project by being assigned group_role - defaults to $${project_name}-editors | string | `""` | no |
| group\_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `"roles/editor"` | no |
| impersonate\_service\_account | An optional service account to impersonate. If this service account is not specified, Terraform will fall back to credential file or Application Default Credentials. | string | `""` | no |
| labels | Map of labels for project | map(string) | `<map>` | no |
| lien | Add a lien on the project to prevent accidental deletion | string | `"false"` | no |
| name | The name for the project | string | n/a | yes |
| org\_id | The organization ID. | string | n/a | yes |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | string | `""` | no |
| python\_interpreter\_path | Python interpreter path for precondition check script. | string | `"python3"` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id` | string | `"false"` | no |
| sa\_group | A G Suite group to place the default Service Account for the project in | string | `""` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | string | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | `""` | no |
| shared\_vpc\_enabled | If shared VPC should be used | bool | `"false"` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list(string) | `<list>` | no |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module) | bool | `"false"` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `""` | no |
| use\_tf\_google\_credentials\_env\_var | Use GOOGLE_CREDENTIALS environment variable to run gcloud auth activate-service-account with. | bool | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain | The organization's domain |
| group\_email | The email of the created G Suite group with group_name |
| group\_name | The group_name of the G Suite group |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id |  |
| project\_name |  |
| project\_number |  |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

[examples]: ../../examples/
[root-module]: ../../README.md
