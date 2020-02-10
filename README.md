# Google Cloud Project Factory Terraform Module

[FAQ](./docs/FAQ.md) | [Troubleshooting Guide](./docs/TROUBLESHOOTING.md) |
[Glossary][glossary].

This module allows you to create opinionated Google Cloud Platform projects. It
creates projects and configures aspects like Shared VPC connectivity, IAM
access, Service Accounts, and API enablement to follow best practices.

To include G Suite integration for creating groups and adding Service Accounts into groups, use the
[gsuite_enabled module][gsuite-enabled-module].

## Compatibility

This module is meant for use with Terraform 0.12. If you haven't
[upgraded][terraform-0.12-upgrade] and need a Terraform
0.11.x-compatible version of this module, the last released version
intended for Terraform 0.11.x is [2.4.1].

## Upgrading

The current version is 6.X. The following guides are available to assist with upgrades:

- [0.X -> 1.0](./docs/upgrading_to_project_factory_v1.0.md)
- [1.X -> 2.0](./docs/upgrading_to_project_factory_v2.0.md)
- [3.X -> 4.0](./docs/upgrading_to_project_factory_v4.0.md)
- [4.X -> 5.0](./docs/upgrading_to_fabric_project_v5.0.md)
- [5.X -> 6.0](./docs/upgrading_to_project_factory_v6.0.md)

## Usage

There are multiple examples included in the [examples](./examples/) folder but simple usage is as follows:

```hcl
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 7.0"

  name                = "pf-test-1"
  random_project_id   = "true"
  org_id              = "1234567890"
  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
  billing_account     = "ABCDEF-ABCDEF-ABCDEF"
  shared_vpc          = "shared_vpc_host_name"

  shared_vpc_subnets = [
    "projects/base-project-196723/regions/us-east1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
  ]
}
```

## Features

The Project Factory module will take the following actions:

1. Create a new GCP project using the `project_name`.
1. If a shared VPC is specified, attach the new project to the
   `shared_vpc`.

   It will also give the following users network access on the specified subnets:

   - The project's new default service account (see step 4)
   - The Google API service account for the project
   - The project controlling group specified in `group_name`

1. Delete the default compute service account.
1. Create a new default service account for the project.
    1. Give it access to the shared VPC
       (to be able to launch instances).
1. Attach the billing account (`billing_account`) to the project.
1. Give the controlling group access to the project, with the `group_role`.
1. Enable the required and specified APIs (`activate_apis`).
1. Delete the default network.
1. Enable usage report for GCE into central project bucket
   (`target_usage_bucket`), if provided.
1. If specified, create the GCS bucket `bucket_name` and give the
   following accounts Storage Admin on it:
   1. The controlling group (`group_name`).
   1. The new default compute service account created for the project.
   1. The Google APIs service account for the project.

The roles granted are specifically:

- New Default Service Account
  - `compute.networkUser` on host project or specified subnets
  - `storage.admin` on `bucket_name` GCS bucket
- `group_name` is the controlling group
  - `compute.networkUser` on host project or specific subnets
  - Specified `group_role` on project
  - `iam.serviceAccountUser` on the default Service Account
  - `storage.admin` on `bucket_name` GCS bucket
- Google APIs Service Account
  - `compute.networkUser` on host project or specified subnets
  - `storage.admin` on `bucket_name` GCS bucket

### Shared VPC subnets and IAM permissions

A service project's access to shared VPC networks is controlled via the
`roles/compute.networkUser` role and the location to where that role is
assigned. If that role is assigned to the shared VPC host project, then the
service project will have access to **all** shared VPC subnetworks. If that role
is assigned to individual subnetworks, then the service project will have
access to only the subnetworks on which that role was assigned. The logic for
determining that location is as follows:

1. If `var.shared_vpc` and `var.shared_vpc_subnets` are not set then the `compute.networkUser` role is not assigned
1. If `var.shared_vpc` is set but no subnetworks are provided via `var.shared_vpc_subnets` then the `compute.networkUser` role is assigned at the host project and the service project will have access to all shared VPC subnetworks
1. If `var.shared_vpc` is set and `var.shared_vpc_subnets` contains an array of subnetworks then the `compute.networkUser` role is assigned to each subnetwork in the array

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list(string) | `<list>` | no |
| auto\_create\_network | Create the default network | bool | `"false"` | no |
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| bucket\_location | The location for a GCS bucket to create (optional) | string | `"US"` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `""` | no |
| budget\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | string | `"null"` | no |
| budget\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | list(number) | `<list>` | no |
| budget\_amount | The amount to use for a budget alert | number | `"null"` | no |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | string | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | string | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | bool | `"true"` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | string | `"true"` | no |
| domain | The domain name (optional). | string | `""` | no |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| group\_name | A group to control the project by being assigned group_role (defaults to project editor) | string | `""` | no |
| group\_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `"roles/editor"` | no |
| impersonate\_service\_account | An optional service account to impersonate. This cannot be used with credentials_path. If this service account is not specified and credentials_path is absent, the module will use Application Default Credentials. | string | `""` | no |
| labels | Map of labels for project | map(string) | `<map>` | no |
| lien | Add a lien on the project to prevent accidental deletion | bool | `"false"` | no |
| name | The name for the project | string | n/a | yes |
| org\_id | The organization ID. | string | n/a | yes |
| pip\_executable\_path | Pip executable path for precondition requirements.txt install. | string | `"pip3"` | no |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | string | `""` | no |
| python\_interpreter\_path | Python interpreter path for precondition check script. | string | `"python3"` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id` | bool | `"false"` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | string | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list(string) | `<list>` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| budget\_name | The name of the budget if created |
| domain | The organization's domain |
| group\_email | The email of the G Suite group with group_name |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id |  |
| project\_name |  |
| project\_number |  |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

### Software

-   [gcloud sdk](https://cloud.google.com/sdk/install) >= 269.0.0
-   [jq](https://stedolan.github.io/jq/) >= 1.6
-   [Terraform](https://www.terraform.io/downloads.html) >= 0.12.6
-   [terraform-provider-google] plugin >= 3.1, < 4.0
-   [terraform-provider-google-beta] plugin >= 3.1, < 4.0
-   [terraform-provider-gsuite] plugin 0.1.x if GSuite functionality is desired

#### `terraform-provider-google` version 2.x

Starting with version `6.3.0` of this module, `google_billing_budget` resources can now be created. This increases the minimum `terraform-provider-google` version to `3.1.0`

To continue to use a version `>= 2.1, < 3.1` of the google provider pin this module to `6.2.1`. Or use the `core_project_factory` submodule directly.

```hcl
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 6.2.1"
  ...
}
```

### Permissions

In order to execute this module you must have a Service Account with the
following roles:

- `roles/resourcemanager.folderViewer` on the folder that you want to create the
  project in
- `roles/resourcemanager.organizationViewer` on the organization
- `roles/resourcemanager.projectCreator` on the organization
- `roles/billing.user` on the organization
- `roles/storage.admin` on bucket_project
- If you are using shared VPC:
  - `roles/billing.user` on the organization
  - `roles/compute.xpnAdmin` on the organization
  - `roles/compute.networkAdmin` on the organization
  - `roles/browser` on the Shared VPC host project
  - `roles/resourcemanager.projectIamAdmin` on the Shared VPC host project

#### Script Helper

A [helper script](./helpers/setup-sa.sh) is included to create the Seed Service
Account in the [Seed Project](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/docs/GLOSSARY.md#seed-project),
grant the necessary roles to the [Seed Service Account](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/docs/GLOSSARY.md#seed-service-account),
and enable the necessary API's in the Seed Project.  Run it as follows:

```sh
./helpers/setup-sa.sh <ORGANIZATION_ID> <SEED_PROJECT_NAME> [BILLING_ACCOUNT]
```

In order to execute this script, you must have an account with the following list of
permissions:

- `resourcemanager.organizations.list`
- `resourcemanager.projects.list`
- `billing.accounts.list`
- `iam.serviceAccounts.create`
- `iam.serviceAccountKeys.create`
- `resourcemanager.organizations.setIamPolicy`
- `resourcemanager.projects.setIamPolicy`
- `serviceusage.services.enable` on the project
- `servicemanagement.services.bind` on following services:
  - cloudresourcemanager.googleapis.com
  - cloudbilling.googleapis.com
  - iam.googleapis.com
  - admin.googleapis.com
  - appengine.googleapis.com
- `billing.accounts.getIamPolicy` on a billing account.
- `billing.accounts.setIamPolicy` on a billing account.

#### Specifying credentials

The Project Factory uses external scripts to perform a few tasks that are not implemented
by Terraform providers. Because of this the Project Factory needs a copy of service account
credentials to pass to these scripts. Credentials can be provided via two mechanisms:

1. Explicitly passed to the Project Factory with the `credentials_path` variable. This approach
   typically uses the same credentials for the `google` provider and the Project Factory:
    ```terraform
    provider "google" {
      credentials = "${file(var.credentials_path)}"
      version = "~> 3.3"
    }

    module "project-factory" {
      source = "terraform-google-modules/project-factory/google"

      name             = "explicit-credentials"
      credentials_path = "${var.credentials_path}"
      # other variables follow ...
    }
    ```
2. Implicitly provided by the [Application Default Credentials][application-default-credentials]
   flow, which typically uses the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:
   ```terraform
   # `GOOGLE_APPLICATION_CREDENTIALS` must be set in the environment before Terraform is run.
   provider "google" {
     # Terraform will check the `GOOGLE_APPLICATION_CREDENTIALS` variable, so no `credentials`
     # value is needed here.
      version = "~> 3.3"
   }

   module "project-factory" {
      source = "terraform-google-modules/project-factory/google"

      name = "adc-credentials"
      # Project Factory will also check the `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
      # other variables follow ...
   }
   ```

### APIs

In order to operate the Project Factory, you must activate the following APIs on
the base project where the Service Account was created:

- Cloud Resource Manager API - `cloudresourcemanager.googleapis.com`
  [troubleshooting](docs/TROUBLESHOOTING.md#missing-api-cloudresourcemanagergoogleapiscom)
- Cloud Billing API - `cloudbilling.googleapis.com`
  [troubleshooting](docs/TROUBLESHOOTING.md#missing-api-cloudbillinggoogleapiscom)
- Identity and Access Management API - `iam.googleapis.com`
  [troubleshooting](docs/TROUBLESHOOTING.md#missing-api-iamgoogleapiscom)
- Admin SDK - `admin.googleapis.com`
  [troubleshooting](docs/TROUBLESHOOTING.md#missing-api-admingoogleapiscom)

#### Optional APIs

- Google App Engine Admin API - `appengine.googleapis.com`
  [troubleshooting](docs/TROUBLESHOOTING.md#missing-api-appenginegoogleapiscom)
  - Please note that if you are deploying an App Engine Flex application, you should not delete the default compute service account
    (as is default behavior). Please see the [troubleshooting doc](docs/TROUBLESHOOTING.md#cannot-deploy-app-engine-flex-application) for more information.

### Verifying setup

A [preconditions checker script][preconditions-checker-script] is
included to verify that all preconditions are met before the Project Factory
runs. The script will run automatically if the script dependencies (Python,
"google-auth", and "google-api-python-client") are available at runtime. If the
dependencies are not met, the precondition checking step will be skipped.

The precondition checker script can be directly invoked before running the
project factory:

```sh
./modules/core_project_factory/scripts/preconditions/preconditions.py \
  --credentials_path "./credentials.json" \
  --billing_account 000000-000000-000000 \
  --org_id 000000000000 \
  --folder_id 000000000000 \
  --shared_vpc 'shared-vpc-host-ed64'
```

## Caveats

### Moving projects from org into a folder

There is currently a bug with moving a project which was originally created at
the root of the organization into a folder. The bug and workaround is described
[here](https://github.com/terraform-providers/terraform-provider-google/issues/1701),
but as a general best practice it is easier to create all projects within
folders to start. Moving projects between different folders *is* supported.

## G Suite

The core Project Factory solely deals with GCP APIs and does not integrate G Suite functionality. If you would like certain group-management functionality which was previously included in the Project Factory, see the [G Suite module][gsuite-enabled-module].

## Install
### Terraform

Be sure you have the correct Terraform version (0.12.6+), you can choose the
binary here:

- https://releases.hashicorp.com/terraform/

[gsuite-enabled-module]: modules/gsuite_enabled/README.md
[preconditions-checker-script]: modules/core_project_factory/scripts/preconditions/preconditions.py
[terraform-provider-google]: https://github.com/terraform-providers/terraform-provider-google
[terraform-provider-google-beta]: https://github.com/terraform-providers/terraform-provider-google-beta
[terraform-provider-gsuite]: https://github.com/DeviaVir/terraform-provider-gsuite
[glossary]: /docs/GLOSSARY.md
[application-default-credentials]: https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application

[2.4.1]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/2.4.1
[terraform-0.12-upgrade]: https://www.terraform.io/upgrade-guides/0-12.html
