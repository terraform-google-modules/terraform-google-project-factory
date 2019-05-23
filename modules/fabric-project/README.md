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
  parent_id                 = "1234567890"
  parent_type               = "folder"
  billing_account           = "ABCD-1234-ABCD-1234"
  prefix                    = "staging"
  name                      = "myproject"
  oslogin                   = true
  owners                    = ["group:admins@example.com"]
  oslogin_admins            = ["group:admins@example.com"]
  gce_service_account_roles = ["foo-project:roles/compute.networkUser"]
}
```

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | Service APIs to enable. | list | `<list>` | no |
| auto\_create\_network | Whether to create the default network for the project | string | `"false"` | no |
| billing\_account | Billing account id. | string | `""` | no |
| custom\_roles | Map of role name => comma-delimited list of permissions to create in this project. | map | `<map>` | no |
| editors | Optional list of IAM-format members to set as project editor. | list | `<list>` | no |
| extra\_bindings\_members | List of comma-delimited IAM-format members for additional IAM bindings, one item per role. | list | `<list>` | no |
| extra\_bindings\_roles | List of roles for additional IAM bindings, pair with members list below. | list | `<list>` | no |
| gce\_service\_account\_roles | List of project id=>role to assign to the default GCE service account. | list | `<list>` | no |
| labels | Resource labels. | map | `<map>` | no |
| lien\_reason | If non-empty, creates a project lien with this description. | string | `""` | no |
| name | Project name and id suffix. | string | n/a | yes |
| oslogin | Enable oslogin. | string | `"false"` | no |
| oslogin\_admins | List of IAM-format members that will get OS Login admin role. | list | `<list>` | no |
| oslogin\_users | List of IAM-format members that will get OS Login user role. | list | `<list>` | no |
| owners | Optional list of IAM-format members to set as project owners. | list | `<list>` | no |
| parent\_id | Id of the resource under which the folder will be placed. | string | n/a | yes |
| parent\_type | Type of the parent resource, defaults to organization. | string | `"organization"` | no |
| prefix | Prefix used to generate project id and name | string | n/a | yes |
| viewers | Optional list of IAM-format members to set as project viewers. | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| custom\_roles | Ids of the created custom roles. |
| gce\_service\_account | Default GCE service account (depends on services). |
| gke\_service\_account | Default GKE service account (depends on services). |
| number | Project number (depends on services). |
| project\_id | Project id (depends on services). |

[^]: (autogen_docs_end)
