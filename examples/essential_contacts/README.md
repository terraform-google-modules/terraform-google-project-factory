# Essential Contacts

This example illustrates how to use the essential_contacts submodule to assign emails to specific notification types and languages.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | Billing account ID. | `string` | n/a | yes |
| folder\_id | The ID of a folder to host this project. | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | n/a | yes |
| random\_string\_for\_testing | A random string of characters to be appended to resource names to ensure uniqueness | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The GCP project with Essential Contacts |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
