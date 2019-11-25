# full

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | Billing account ID. | string | n/a | yes |
| domain |  | string | n/a | yes |
| folder\_id |  | string | n/a | yes |
| group\_name |  | string | n/a | yes |
| group\_role |  | string | `"roles/viewer"` | no |
| gsuite\_admin\_account |  | string | n/a | yes |
| org\_id | Organization ID. | string | n/a | yes |
| random\_string\_for\_testing | A random string of characters to be appended to resource names to ensure uniqueness | string | n/a | yes |
| region |  | string | `"us-east4"` | no |
| sa\_group |  | string | n/a | yes |
| sa\_role |  | string | `"roles/editor"` | no |
| shared\_vpc |  | string | n/a | yes |
| usage\_bucket\_name |  | string | n/a | yes |
| usage\_bucket\_prefix |  | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| compute\_service\_account\_email |  |
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
