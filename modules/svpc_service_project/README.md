# Shared VPC
This module performs the same functions as the root module with the addition of assigning the project as a Shared VPC service project associated with a given host project and granting IAM permissions on host project and subnets to appropriate API service accounts based on activated APIs.

The advantage of using this module over the root module, is being able to provision both the host project and service projects within a single configuration. See [examples/shared_vpc](../../examples/shared_vpc) for a full example.

## Example Usage
```hcl
module "service-project" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 10.1"

  name                = "pf-test-1"
  random_project_id   = "true"
  org_id              = "1234567890"
  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
  billing_account     = "ABCDEF-ABCDEF-ABCDEF"
  shared_vpc          = module.host-project.project_id

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dataproc.googleapis.com",
    "dataflow.googleapis.com",
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_api\_identities | The list of service identities (Google Managed service account for the API) to force-create for the project (e.g. in order to grant additional roles).<br>    APIs in this list will automatically be appended to `activate_apis`.<br>    Not including the API in this list will follow the default behaviour for identity creation (which is usually when the first resource using the API is created).<br>    Any roles (e.g. service agent role) must be explicitly listed. See https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles for a list of related roles. | <pre>list(object({<br>    api   = string<br>    roles = list(string)<br>  }))</pre> | `[]` | no |
| activate\_apis | The list of apis to activate within the project | `list(string)` | <pre>[<br>  "compute.googleapis.com"<br>]</pre> | no |
| auto\_create\_network | Create the default network | `bool` | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| bucket\_location | The location for a GCS bucket to create (optional) | `string` | `"US"` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket\_project project), useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket\_name) in, useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_versioning | Enable versioning for a GCS bucket to create (optional) | `bool` | `false` | no |
| budget\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| budget\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.7,<br>  1<br>]</pre> | no |
| budget\_amount | The amount to use for a budget alert | `number` | `null` | no |
| budget\_monitoring\_notification\_channels | A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed. | `list(string)` | `[]` | no |
| create\_project\_sa | Whether the default service account for the project shall be created | `bool` | `true` | no |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | `string` | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | `string` | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | `bool` | `true` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | `bool` | `true` | no |
| domain | The domain name (optional). | `string` | `""` | no |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| grant\_services\_security\_admin\_role | Whether or not to grant Kubernetes Engine Service Agent the Security Admin role on the host project so it can manage firewall rules | `bool` | `false` | no |
| group\_name | A group to control the project by being assigned group\_role (defaults to project editor) | `string` | `""` | no |
| group\_role | The role to give the controlling group (group\_name) over the project (defaults to project editor) | `string` | `"roles/editor"` | no |
| impersonate\_service\_account | An optional service account to impersonate. This cannot be used with credentials\_path. If this service account is not specified and credentials\_path is absent, the module will use Application Default Credentials. | `string` | `""` | no |
| labels | Map of labels for project | `map(string)` | `{}` | no |
| lien | Add a lien on the project to prevent accidental deletion | `bool` | `false` | no |
| name | The name for the project | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | n/a | yes |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | `string` | `""` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id` | `bool` | `false` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | `string` | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | `string` | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project\_id/regions/$region/subnetworks/$subnet\_id) | `list(string)` | `[]` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain | The organization's domain |
| group\_email | The email of the G Suite group with group\_name |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | If provided, the project uses the given project ID. Mutually exclusive with random\_project\_id being true. |
| project\_name | The name for the project |
| project\_number | The number for the project |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
