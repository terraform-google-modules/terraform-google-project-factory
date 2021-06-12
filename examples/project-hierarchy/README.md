# Project Hierarchy

This is example illustrates how to set up a project hierarchy.

It will do the following:
- Create a folder on an organization
- Create two projects under the newly created folder

Note: this example requires for the service account used by terraform to have the role resourcemanager.folderCreator . You can grant this role with the command "gcloud organizations add-iam-policy-binding" as in the example below

```
gcloud organizations add-iam-policy-binding 1092662220185 \
  --member="serviceAccount:project-factory-12782@terraform-213322.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.folderCreator"
```

Expected variables:
- `admin_email`
- `organization_id`
- `billing_account`
- `credentials_path`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_email | Admin user email on Gsuite | `any` | n/a | yes |
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| organization\_id | The organization id for the associated services | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created prod\_gke project |
| project\_info\_factory\_example | The ID of the created factory project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
