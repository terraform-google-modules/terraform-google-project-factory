# core_project_factory

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate_apis | The list of apis to activate within the project | list | `<list>` | no |
| auto_create_network | Create the default network | string | `false` | no |
| billing_account | The ID of the billing account to associate this project with | string | - | yes |
| bucket_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `` | no |
| bucket_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `` | no |
| credentials_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |
| disable_services_on_destroy | Whether project services will be disabled when the resources are destroyed | string | `true` | no |
| folder_id | The ID of a folder to host this project | string | `` | no |
| group_email | The email address of a group to control the project by being assigned group_role. | string | - | yes |
| group_role | The role to give the controlling group (group_name) over the project. | string | `` | no |
| labels | Map of labels for project | map | `<map>` | no |
| lien | Add a lien on the project to prevent accidental deletion | string | `false` | no |
| manage_group | A toggle to indicate if a G Suite group should be managed. | string | `false` | no |
| name | The name for the project | string | - | yes |
| org_id | The organization ID. | string | - | yes |
| random_project_id | Enables project random id generation | string | `false` | no |
| sa_role | A role to give the default Service Account for the project (defaults to none) | string | `` | no |
| shared_vpc | The ID of the host project which hosts the shared VPC | string | `` | no |
| shared_vpc_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list | `<list>` | no |
| usage_bucket_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `` | no |
| usage_bucket_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_s_account | API service account email |
| api_s_account_fmt | API service account email formatted for terraform use |
| project_bucket_name | The name of the projec's bucket |
| project_bucket_self_link | Project's bucket selfLink |
| project_bucket_url | Project's bucket url |
| project_id |  |
| project_number |  |
| service_account_display_name | The display name of the default service account |
| service_account_email | The email of the default service account |
| service_account_id | The id of the default service account |
| service_account_name | The fully-qualified name of the default service account |
| service_account_unique_id | The unique id of the default service account |

[^]: (autogen_docs_end)