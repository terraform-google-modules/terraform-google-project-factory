# Essential Contacts configuration

This module uses the [`google_essential_contacts_contact`](https://www.terraform.io/docs/providers/google/r/google_project_service.html)
resource to add contact emails which will receive notification types from Google Cloud, using specified subcription types.

## Prerequisites

1. Service account used to run Terraform has permission to administer Essential Contacts:
[`roles/essentialcontacts.admin`](https://cloud.google.com/iam/docs/understanding-roles#other-roles).
2. The target project has the Essential Contacts API enabled `essentialcontacts.googleapis.com `

## Example Usage
```
module "essential_contacts" {
  source     = "../../modules/essential_contacts"
  project_id = var.project_id

  essential_contacts = {
    "user1@foo.com"    = ["ALL"],
    "security@foo.com" = ["SECURITY", "TECHNICAL"],
    "app@foo.com"      = ["TECHNICAL"]
  }

  language_tag = "en-US"
}
```

See [examples/essential_contacts](./examples/essential_contacts) for a full example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| essential\_contacts | A mapping of users or groups to be assigned as Essential Contacts to the project, specifying a notification category | `map(list(string))` | `{}` | no |
| language\_tag | Language code to be used for essential contacts notifiactions | `string` | n/a | yes |
| project\_id | The GCP project you want to send Essential Contacts notifications for | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| essential\_contacts | Essential Contact resources created |
| project\_id | The GCP project you want to enable APIs on |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
