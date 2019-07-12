# full

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account |  | string | n/a | yes |
| create\_group |  | string | `"false"` | no |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. This is required for the `full` test fixture. | string | `""` | no |
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
| usage\_bucket\_name |  | string | `""` | no |
| usage\_bucket\_prefix |  | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain |  |
| extra\_service\_account\_email |  |
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
| shared\_vpc\_subnet\_name\_01 |  |
| shared\_vpc\_subnet\_name\_02 |  |
| shared\_vpc\_subnet\_region\_01 |  |
| shared\_vpc\_subnet\_region\_02 |  |
| usage\_bucket\_name |  |
| usage\_bucket\_prefix |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
