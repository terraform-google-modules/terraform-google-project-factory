# minimal

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account |  | string | n/a | yes |
| create\_group |  | bool | `"false"` | no |
| domain |  | string | n/a | yes |
| folder\_id |  | string | `""` | no |
| group\_name |  | string | `""` | no |
| group\_role |  | string | `"roles/viewer"` | no |
| gsuite\_admin\_account |  | string | n/a | yes |
| org\_id |  | string | n/a | yes |
| random\_string\_for\_testing | A random string of characters to be appended to resource names to ensure uniqueness | string | n/a | yes |
| region |  | string | `"us-east4"` | no |
| sa\_group |  | string | `""` | no |
| sa\_role |  | string | `"roles/editor"` | no |
| shared\_vpc |  | string | `""` | no |
| shared\_vpc\_enabled | If shared VPC should be used | bool | `"false"` | no |
| usage\_bucket\_name |  | string | `""` | no |
| usage\_bucket\_prefix |  | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain |  |
| group\_email |  |
| group\_role |  |
| gsuite\_admin\_account |  |
| project\_id |  |
| project\_name |  |
| project\_number |  |
| region |  |
| sa\_role |  |
| service\_account\_email |  |
| shared\_vpc |  |
| usage\_bucket\_name |  |
| usage\_bucket\_prefix |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
