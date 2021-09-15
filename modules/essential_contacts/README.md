# Essential Contacts configuration

This optional module is used to enable project APIs in your project. The list of
APIs to be enabled is specified using the `essential_contacts_config` variable.

This module uses the [`google_essential_contacts_contact`](https://www.terraform.io/docs/providers/google/r/google_project_service.html)
resource to add contact emails which will receive notification types from Google Cloud, using specified subcription types.


## Prerequisites

1. Service account used to run Terraform has permission to administer Essential Contacts:
[`roles/essentialcontacts.admin`](https://cloud.google.com/iam/docs/understanding-roles#other-roles).

## Example Usage
```
module "essential-contacts" {
  source  = "terraform-google-modules/project-factory/google//modules/essential_contacts"
  version = "10.1.1"

  project_id                  = "my-project-id"

  essential_contacts_config = [
    {
      notification_category_subscriptions = ["ALL"]
      language_tag              = "en-US"
      contacts = [
        "user1@foo.com",
        "group1@foo.com"
      ]
    }
  ]
}
```

See [examples/essential_contacts](./examples/essential_contacts) for a full example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| essential\_contacts | A mapping of users or groups to be assigned as Essential Contacts to the project, specifying a notification category | `map(list(string))` | `{}` | no |
| language\_tag | Language code to be used for essential contacts notifiactions | `string` | n/a | yes |
| project\_id | The GCP project you want to send Essential Contacts notifications for | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The GCP project you want to enable APIs on |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
