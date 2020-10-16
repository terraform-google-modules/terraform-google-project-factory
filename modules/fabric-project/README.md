# Google Cloud Simple Project Creation

This module allows simple Google Cloud Platform project creation, with minimal service and project-level IAM binding management. It's designed to be used for architectural design and rapid prototyping, as part of the [Cloud Foundation Fabric](https://github.com/terraform-google-modules/cloud-foundation-fabric) environments.

The resources/services/activations/deletions that this module will create/trigger are:

- one project
- zero or one project metadata items for OSLogin activation
- zero or more project service activations
- zero or more project-level IAM bindings
- zero or more project-level custom roles
- zero or one project liens

## Usage

Basic usage of this module is as follows:

```hcl
module "project_myproject" {
  source                    = "terraform-google-modules/project-factory/google//modules/fabric-project"
  parent                    = "folders/1234567890"
  billing_account           = "ABCD-1234-ABCD-1234"
  prefix                    = "staging"
  name                      = "myproject"
  oslogin                   = true
  owners                    = ["group:admins@example.com"]
  oslogin_admins            = ["group:admins@example.com"]
  gce_service_account_roles = ["foo-project:roles/compute.networkUser"]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | Service APIs to enable. | `list(string)` | `[]` | no |
| auto\_create\_network | Whether to create the default network for the project | `bool` | `false` | no |
| billing\_account | Billing account id. | `string` | `""` | no |
| custom\_roles | Map of role name => comma-delimited list of permissions to create in this project. | `map(string)` | `{}` | no |
| editors | Optional list of IAM-format members to set as project editor. | `list(string)` | `[]` | no |
| extra\_bindings\_members | List of comma-delimited IAM-format members for additional IAM bindings, one item per role. | `list(string)` | `[]` | no |
| extra\_bindings\_roles | List of roles for additional IAM bindings, pair with members list below. | `list(string)` | `[]` | no |
| gce\_service\_account\_roles | List of project id=>role to assign to the default GCE service account. | `list(string)` | `[]` | no |
| labels | Resource labels. | `map(string)` | `{}` | no |
| lien\_reason | If non-empty, creates a project lien with this description. | `string` | `""` | no |
| name | Project name and id suffix. | `string` | n/a | yes |
| oslogin | Enable oslogin. | `bool` | `false` | no |
| oslogin\_admins | List of IAM-format members that will get OS Login admin role. | `list(string)` | `[]` | no |
| oslogin\_users | List of IAM-format members that will get OS Login user role. | `list(string)` | `[]` | no |
| owners | Optional list of IAM-format members to set as project owners. | `list(string)` | `[]` | no |
| parent | The resource name of the parent Folder or Organization. Must be of the form folders/folder\_id or organizations/org\_id. | `string` | n/a | yes |
| prefix | Prefix used to generate project id and name. | `string` | n/a | yes |
| viewers | Optional list of IAM-format members to set as project viewers. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudsvc\_service\_account | Cloud services service account (depends on services). |
| custom\_roles | Ids of the created custom roles. |
| gce\_service\_account | Default GCE service account (depends on services). |
| gke\_service\_account | Default GKE service account (depends on services). |
| name | Name (depends on services). |
| number | Project number (depends on services). |
| project\_id | Project id (depends on services). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
