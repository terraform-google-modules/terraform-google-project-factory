# Core Project Factory


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_api\_identities | The list of service identities (Google Managed service account for the API) to force-create for the project (e.g. in order to grant additional roles).<br>    APIs in this list will automatically be appended to `activate_apis`. Use for services supported by `gcloud beta services identity create`<br>    Not including the API in this list will follow the default behaviour for identity creation (which is usually when the first resource using the API is created).<br>    Any roles (e.g. service agent role) must be explicitly listed. See https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles for a list of related roles. | <pre>list(object({<br>    api   = string<br>    roles = list(string)<br>  }))</pre> | `[]` | no |
| activate\_apis | The list of apis to activate within the project | `list(string)` | <pre>[<br>  "compute.googleapis.com"<br>]</pre> | no |
| auto\_create\_network | Create the default network | `bool` | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| bucket\_force\_destroy | Force the deletion of all objects within the GCS bucket when deleting the bucket (optional) | `bool` | `false` | no |
| bucket\_labels | A map of key/value label pairs to assign to the bucket (optional) | `map(string)` | `{}` | no |
| bucket\_location | The location for a GCS bucket to create (optional) | `string` | `"US"` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket\_project project), useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_pap | Enable Public Access Prevention. Possible values are "enforced" or "inherited". | `string` | `"inherited"` | no |
| bucket\_project | A project to create a GCS bucket (bucket\_name) in, useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_ula | Enable Uniform Bucket Level Access | `bool` | `true` | no |
| bucket\_versioning | Enable versioning for a GCS bucket to create (optional) | `bool` | `false` | no |
| create\_project\_sa | Whether the default service account for the project shall be created | `bool` | `true` | no |
| default\_network\_tier | Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers. | `string` | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | `string` | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | `bool` | `true` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | `bool` | `true` | no |
| enable\_shared\_vpc\_host\_project | If this project is a shared VPC host project. If true, you must *not* set shared\_vpc variable. Default is false. | `bool` | `false` | no |
| enable\_shared\_vpc\_service\_project | If this project should be attached to a shared VPC. If true, you must set shared\_vpc variable. | `bool` | n/a | yes |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| grant\_network\_role | Whether or not to grant networkUser role on the host project/subnets | `bool` | `true` | no |
| group\_email | The email address of a group to control the project by being assigned group\_role. | `string` | `""` | no |
| group\_role | The role to give the controlling group (group\_name) over the project. | `string` | `""` | no |
| labels | Map of labels for project | `map(string)` | `{}` | no |
| lien | Add a lien on the project to prevent accidental deletion | `bool` | `false` | no |
| manage\_group | A toggle to indicate if a G Suite group should be managed. | `bool` | `false` | no |
| name | The name for the project | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | `null` | no |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | `string` | `""` | no |
| project\_sa\_name | Default service account name for the project. | `string` | `"project-service-account"` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id`. | `bool` | `false` | no |
| random\_project\_id\_length | Sets the length of `random_project_id` to the provided length, and uses a `random_string` for a larger collusion domain.  Recommended for use with CI. | `number` | `null` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | `string` | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | `string` | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project\_id/regions/$region/subnetworks/$subnet\_id) | `list(string)` | `[]` | no |
| tag\_binding\_values | Tag values to bind the project to. | `list(string)` | `[]` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| vpc\_service\_control\_attach\_dry\_run | Whether the project will be attached to a VPC Service Control Perimeter in Dry Run Mode. vpc\_service\_control\_attach\_enabled should be false for this to be true | `bool` | `false` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE. vpc\_service\_control\_attach\_dry\_run should be false for this to be true | `bool` | `false` | no |
| vpc\_service\_control\_perimeter\_name | The name of a VPC Service Control Perimeter to add the created project to | `string` | `null` | no |
| vpc\_service\_control\_sleep\_duration | The duration to sleep in seconds before adding the project to a shared VPC after the project is added to the VPC Service Control Perimeter. VPC-SC is eventually consistent. | `string` | `"5s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_s\_account | API service account email |
| api\_s\_account\_fmt | API service account email formatted for terraform use |
| enabled\_api\_identities | Enabled API identities in the project |
| enabled\_apis | Enabled APIs in the project |
| project\_bucket\_name | The name of the projec's bucket |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | ID of the project |
| project\_name | Name of the project |
| project\_number | Numeric identifier for the project |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |
| tag\_bindings | Tag bindings |
| usage\_report\_export\_bucket | GCE usage reports bucket |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
