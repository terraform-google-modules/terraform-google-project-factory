# Google Cloud Project Factory with G Suite Terraform Module

This module performs the same functions as the
[root module][root-module] with the addition of integrating G Suite.

## Usage

There are multiple examples included in the [examples] folder but simple usage is as follows:

```hcl
module "project-factory" {
  source = "terraform-google-modules/project-factory/google//modules/gsuite_enabled"
  version = "0.2.1"

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
1. Give the group access to the project with the `group_role`.
1. Give the project controlling group specified in `group_name` network
   access on the specified subnets if `shared_vpc` is specified.
1. Add the new default service account for the project to the
   `sa_group` in Google Groups, if specified.
1. Give the group Storage Admin on `bucket_name`, if specified.
1. Add the Google APIs service account to the `api_sa_group`,
   if specified.

The roles granted are specifically:

- New Default Service Account
  - MEMBER of the specified `sa_group`
- `group_name` is the new controlling group
  - `compute.networkUser` on host project or specific subnets
  - Specified `group_role` on project
  - `iam.serviceAccountUser` on the default Service Account
  - `storage.admin` on `bucket_name` GCS bucket
- Google APIs Service Account
  - MEMBER of the specified `api_sa_group`

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list | `<list>` | no |
| api\_sa\_group | A GSuite group to place the Google APIs Service Account for the project in | string | `` | no |
| app\_engine | A map for app engine configuration | map | `<map>` | no |
| auto\_create\_network | Create the default network | string | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | string | - | yes |
| bucket\_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `` | no |
| bucket\_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `` | no |
| create\_group | Whether to create the group or not | string | `false` | no |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |
| domain | The domain name (optional if `org_id` is passed) | string | `` | no |
| folder\_id | The ID of a folder to host this project | string | `` | no |
| group\_name | A group to control the project by being assigned group_role - defaults to ${project_name}-editors | string | `` | no |
| group\_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `roles/editor` | no |
| labels | Map of labels for project | map | `<map>` | no |
| name | The name for the project | string | - | yes |
| org\_id | The organization id for the associated services | string | `` | no |
| random\_project\_id | Enables project random id generation | string | `false` | no |
| sa\_group | A GSuite group to place the default Service Account for the project in | string | `` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | string | `` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | `` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list | `<list>` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_engine\_enabled | Whether app engine is enabled |
| domain | The organization's domain |
| group\_email | The email of the created GSuite group with group_name |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | - |
| project\_number | - |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

[^]: (autogen_docs_end)

[examples]: ../../examples/
[root-module]: ../../README.md
