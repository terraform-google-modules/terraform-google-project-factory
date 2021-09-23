# Google Cloud Project Factory Terraform Module

[FAQ](./docs/FAQ.md) | [Troubleshooting Guide](./docs/TROUBLESHOOTING.md) |
[Glossary][glossary].

This module allows you to create opinionated Google Cloud Platform projects. It
creates projects and configures aspects like Shared VPC connectivity, IAM
access, Service Accounts, and API enablement to follow best practices.

To include G Suite integration for creating groups and adding Service Accounts into groups, use the
[gsuite_enabled module][gsuite-enabled-module].

## Compatibility

This module is meant for use with Terraform 0.13. If you haven't
[upgraded][terraform-0.13-upgrade] and need a Terraform
0.12.x-compatible version of this module, the last released version
intended for Terraform 0.12.x is [9.2.0].

## Upgrading

See the [docs](./docs) for detailed instructions on upgrading between major releases of the module.

## Usage

There are multiple examples included in the [examples](./examples/) folder but simple usage is as follows:

```hcl
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"

  name                 = "pf-test-1"
  random_project_id    = true
  org_id               = "1234567890"
  usage_bucket_name    = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix  = "pf/test/1/integration"
  billing_account      = "ABCDEF-ABCDEF-ABCDEF"
  svpc_host_project_id = "shared_vpc_host_name"

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
   `svpc_host_project_id`.

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

1. If `var.svpc_host_project_id` and `var.shared_vpc_subnets` are not set then the `compute.networkUser` role is not assigned
1. If `var.svpc_host_project_id` is set but no subnetworks are provided via `var.shared_vpc_subnets` then the `compute.networkUser` role is assigned at the host project and the service project will have access to all shared VPC subnetworks
1. If `var.svpc_host_project_id` is set and `var.shared_vpc_subnets` contains an array of subnetworks then the `compute.networkUser` role is assigned to each subnetwork in the array

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_api\_identities | The list of service identities (Google Managed service account for the API) to force-create for the project (e.g. in order to grant additional roles).<br>    APIs in this list will automatically be appended to `activate_apis`.<br>    Not including the API in this list will follow the default behaviour for identity creation (which is usually when the first resource using the API is created).<br>    Any roles (e.g. service agent role) must be explicitly listed. See https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles for a list of related roles. | <pre>list(object({<br>    api   = string<br>    roles = list(string)<br>  }))</pre> | `[]` | no |
| activate\_apis | The list of apis to activate within the project | `list(string)` | <pre>[<br>  "compute.googleapis.com"<br>]</pre> | no |
| auto\_create\_network | Create the default network | `bool` | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| bucket\_force\_destroy | Force the deletion of all objects within the GCS bucket when deleting the bucket (optional) | `bool` | `false` | no |
| bucket\_labels | A map of key/value label pairs to assign to the bucket (optional) | `map` | `{}` | no |
| bucket\_location | The location for a GCS bucket to create (optional) | `string` | `"US"` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket\_project project), useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket\_name) in, useful for Terraform state (optional) | `string` | `""` | no |
| bucket\_ula | Enable Uniform Bucket Level Access | `bool` | `true` | no |
| bucket\_versioning | Enable versioning for a GCS bucket to create (optional) | `bool` | `false` | no |
| budget\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| budget\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.7,<br>  1<br>]</pre> | no |
| budget\_amount | The amount to use for a budget alert | `number` | `null` | no |
| budget\_display\_name | The display name of the budget. If not set defaults to `Budget For <projects[0]|All Projects>` | `string` | `null` | no |
| budget\_monitoring\_notification\_channels | A list of monitoring notification channels in the form `[projects/{project_id}/notificationChannels/{channel_id}]`. A maximum of 5 channels are allowed. | `list(string)` | `[]` | no |
| consumer\_quotas | The quotas configuration you want to override for the project. | <pre>list(object({<br>    service = string,<br>    metric  = string,<br>    limit   = string,<br>    value   = string,<br>  }))</pre> | `[]` | no |
| create\_project\_sa | Whether the default service account for the project shall be created | `bool` | `true` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | `string` | `"disable"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | `bool` | `true` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | `bool` | `true` | no |
| domain | The domain name (optional). | `string` | `""` | no |
| enable\_shared\_vpc\_host\_project | If this project is a shared VPC host project. If true, you must *not* set svpc\_host\_project\_id variable. Default is false. | `bool` | `false` | no |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| grant\_services\_network\_role | Whether or not to grant service agents the network roles on the host project | `bool` | `true` | no |
| grant\_services\_security\_admin\_role | Whether or not to grant Kubernetes Engine Service Agent the Security Admin role on the host project so it can manage firewall rules | `bool` | `false` | no |
| group\_name | A group to control the project by being assigned group\_role (defaults to project editor) | `string` | `""` | no |
| group\_role | The role to give the controlling group (group\_name) over the project (defaults to project editor) | `string` | `"roles/editor"` | no |
| labels | Map of labels for project | `map(string)` | `{}` | no |
| lien | Add a lien on the project to prevent accidental deletion | `bool` | `false` | no |
| name | The name for the project | `string` | n/a | yes |
| org\_id | The organization ID. | `string` | n/a | yes |
| project\_id | The ID to give the project. If not provided, the `name` will be used. | `string` | `""` | no |
| project\_sa\_name | Default service account name for the project. | `string` | `"project-service-account"` | no |
| random\_project\_id | Adds a suffix of 4 random characters to the `project_id` | `bool` | `false` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | `string` | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project\_id/regions/$region/subnetworks/$subnet\_id) | `list(string)` | `[]` | no |
| svpc\_host\_project\_id | The ID of the host project which hosts the shared VPC | `string` | `""` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | `string` | `""` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter | `bool` | `false` | no |
| vpc\_service\_control\_perimeter\_name | The name of a VPC Service Control Perimeter to add the created project to | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_s\_account | API service account email |
| api\_s\_account\_fmt | API service account email formatted for terraform use |
| budget\_name | The name of the budget if created |
| domain | The organization's domain |
| enabled\_api\_identities | Enabled API identities in the project |
| enabled\_apis | Enabled APIs in the project |
| group\_email | The email of the G Suite group with group\_name |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | n/a |
| project\_name | n/a |
| project\_number | n/a |
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
-   [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
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
./helpers/setup-sa.sh -o <organization id> -p <project id> [-b <billing account id>] [-f <folder id>] [-n <service account name>]
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
- Cloud Billing Budget API - `billingbudgets.googleapis.com`
  - Please note this API is only required if configuring budgets for projects.

### Verifying setup

A [preconditions checker script][preconditions-checker-script] is
included to verify that all preconditions are met before the Project Factory
runs. The script will run automatically if the script dependencies (Python,
"google-auth", and "google-api-python-client") are available at runtime. If the
dependencies are not met, the precondition checking step will be skipped.

The precondition checker script can be directly invoked before running the
project factory:

```sh
./helpers/preconditions/preconditions.py \
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

### Deleting default service accounts

[Default SAs](https://cloud.google.com/iam/docs/service-accounts#default) can be removed by setting `default_service_account` input variable to `delete`, but there can be certain scenarios where the default SAs are required. Hence some considerations to be aware of:
1. [Using App Engine SA](https://cloud.google.com/appengine/docs/flexible/python/default-service-account).
1. Cloud Scheduler dependency on AppEngine(default SA). Default SA is required to be able to setup [Cloud scheduler](https://cloud.google.com/scheduler/docs/setup#use_gcloud_to_create_a_project_with_an_app_engine_app), please refer to the [document](https://cloud.google.com/scheduler/docs/setup#use_gcloud_to_create_a_project_with_an_app_engine_app) for more upto date information.

With a combination of project-factory's default behavior, [disable](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/variables.tf#L202-L206), and setting [constraints/iam.automaticIamGrantsForDefaultServiceAccounts](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints) org constraint will address removing the default editor IAM role on the SAs and limits the SA usage. However, when the `default_service_account` is set to `delete` please be aware of the default SA dependency for AppEngine/CloudScheduler services. Accounts deleted within 30days can be [restored](https://cloud.google.com/iam/docs/creating-managing-service-accounts#undeleting).

## G Suite

The core Project Factory solely deals with GCP APIs and does not integrate G Suite functionality. If you would like certain group-management functionality which was previously included in the Project Factory, see the [G Suite module][gsuite-enabled-module].

## Install
### Terraform

Be sure you have the correct Terraform version (0.13.0+), you can choose the
binary here:

- https://releases.hashicorp.com/terraform/

[gsuite-enabled-module]: modules/gsuite_enabled/README.md
[preconditions-checker-script]: helpers/preconditions/preconditions.py
[terraform-provider-google]: https://github.com/terraform-providers/terraform-provider-google
[terraform-provider-google-beta]: https://github.com/terraform-providers/terraform-provider-google-beta
[terraform-provider-gsuite]: https://github.com/DeviaVir/terraform-provider-gsuite
[glossary]: /docs/GLOSSARY.md
[application-default-credentials]: https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application

[9.2.0]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/9.2.0
[terraform-0.13-upgrade]: https://www.terraform.io/upgrade-guides/0-13.html
