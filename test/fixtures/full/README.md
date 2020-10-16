# full

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | Billing account ID. | `string` | n/a | yes |
| domain | n/a | `string` | n/a | yes |
| folder\_id | n/a | `string` | n/a | yes |
| group\_name | n/a | `string` | n/a | yes |
| group\_role | n/a | `string` | `"roles/viewer"` | no |
| gsuite\_admin\_account | n/a | `string` | n/a | yes |
| org\_id | Organization ID. | `string` | n/a | yes |
| random\_string\_for\_testing | A random string of characters to be appended to resource names to ensure uniqueness | `string` | n/a | yes |
| region | n/a | `string` | `"us-east4"` | no |
| sa\_group | n/a | `string` | n/a | yes |
| sa\_role | n/a | `string` | `"roles/editor"` | no |
| shared\_vpc | n/a | `string` | n/a | yes |
| usage\_bucket\_name | n/a | `string` | n/a | yes |
| usage\_bucket\_prefix | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| compute\_service\_account\_email | n/a |
| domain | n/a |
| extra\_service\_account\_email | n/a |
| group\_email | n/a |
| group\_role | n/a |
| gsuite\_admin\_account | n/a |
| project\_id | n/a |
| project\_name | n/a |
| project\_number | n/a |
| region | n/a |
| sa\_role | n/a |
| service\_account\_email | n/a |
| shared\_vpc | n/a |
| shared\_vpc\_subnet\_name\_01 | n/a |
| shared\_vpc\_subnet\_name\_02 | n/a |
| shared\_vpc\_subnet\_region\_01 | n/a |
| shared\_vpc\_subnet\_region\_02 | n/a |
| usage\_bucket\_name | n/a |
| usage\_bucket\_prefix | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
