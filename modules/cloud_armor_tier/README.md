# Cloud Armor Tier

This module uses the [`google_compute_project_cloud_armor_tier`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_cloud_armor_tier)
resource to set the Cloud Armor tier of the project.

## Prerequisites

1. Service account used to run Terraform has permission to To enroll a project into the Cloud Armor Enterprise subscription
[`resourcemanager.projects.createBillingAssignment` and `resourcemanager.projects.update`](https://cloud.google.com/armor/docs/armor-enterprise-using#required_permissions).
2. The target project has the compute engine API enabled `compute.googleapis.com `

## Example Usage
```
module "cloud_armor_tier" {
  source   = "terraform-google-modules/project-factory/google//module/cloud_armor_tier"
  version  = "16.0"

  project_id       = module.project-factory.project_id
  cloud_armor_tier = var.cloud_armor_tier
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_armor\_tier | Managed protection tier to be set. Possible values are: CA\_STANDARD, CA\_ENTERPRISE\_PAYGO | `string` | n/a | yes |
| project\_id | The GCP project you want to send Essential Contacts notifications for | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_armor\_tier | Cloud Armor tier for the project |
| project\_id | The GCP project you want to enable APIs on |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
