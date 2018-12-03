# gsuite_enabled

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