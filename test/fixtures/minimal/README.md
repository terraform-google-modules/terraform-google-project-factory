# minimal

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing_account |  | string | - | yes |
| create_group |  | string | `false` | no |
| credentials_path |  | string | - | yes |
| domain |  | string | - | yes |
| folder_id |  | string | `` | no |
| group_name |  | string | `` | no |
| group_role |  | string | `roles/viewer` | no |
| gsuite_admin_account |  | string | - | yes |
| org_id |  | string | - | yes |
| region |  | string | `us-east4` | no |
| sa_group |  | string | `` | no |
| sa_role |  | string | `roles/editor` | no |
| shared_vpc |  | string | `` | no |
| usage_bucket_name |  | string | `` | no |
| usage_bucket_prefix |  | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| credentials_path | Pass through the `credentials_path` variable so that InSpec can reuse the credentials |
| domain |  |
| group_email |  |
| group_role |  |
| gsuite_admin_account |  |
| project_id |  |
| project_number |  |
| region |  |
| sa_role |  |
| service_account_email |  |
| shared_vpc |  |
| usage_bucket_name |  |
| usage_bucket_prefix |  |

[^]: (autogen_docs_end)
