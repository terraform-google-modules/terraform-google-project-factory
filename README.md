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

The current version is 3.X. The following guides are available to assist with upgrades:

- [0.X -> 1.0](./docs/upgrading_to_project_factory_v1.0.md)
- [1.X -> 2.0](./docs/upgrading_to_project_factory_v2.0.md)

## Usage

There are multiple examples included in the [examples](./examples/) folder but simple usage is as follows:

```hcl
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 2.0"

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
| apis\_authority | Toggles authoritative management of project services. | string | `"false"` | no |
| auto\_create\_network | Create the default network | string | `"false"` | no |
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| bucket\_location | The location for a GCS bucket to create (optional) | string | `"US"` | no |
| bucket\_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `""` | no |
| bucket\_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `""` | no |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | string | `""` | no |
| default\_service\_account | Project default service account setting: can be one of `delete`, `depriviledge`, or `keep`. | string | `"delete"` | no |
| disable\_dependent\_services | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. | string | `"true"` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | string | `"true"` | no |
| domain | The domain name (optional). | string | `""` | no |
| folder\_id | The ID of a folder to host this project | string | `""` | no |
| group\_name | A group to control the project by being assigned group_role (defaults to project editor) | string | `""` | no |
| group\_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `"roles/editor"` | no |
| impersonate\_service\_account | An optional service account to impersonate. This cannot be used with credentials_path. If this service account is not specified and credentials_path is absent, the module will use Application Default Credentials. | string | `""` | no |
| labels | Map of labels for project | map(string) | `<map>` | no |
| lien | Add a lien on the project to prevent accidental deletion | string | `"false"` | no |
| name | The name for the project | string | n/a | yes |
| org\_id | The organization ID. | string | n/a | yes |
| project\_id | If provided, the project uses the given project ID. Mutually exclusive with random_project_id being true. | string | `""` | no |
| random\_project\_id | Enables project random id generation. Mutually exclusive with project_id being non-empty. | string | `"false"` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | string | `""` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | `""` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list(string) | `<list>` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `""` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain | The organization's domain |
| group\_email | The email of the GSuite group with group_name |
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

-   [gcloud sdk](https://cloud.google.com/sdk/install) >= 206.0.0
-   [jq](https://stedolan.github.io/jq/) >= 1.6
-   [Terraform](https://www.terraform.io/downloads.html) 0.11.x
-   [terraform-provider-google] plugin 2.1.x
-   [terraform-provider-google-beta] plugin 2.1.x
-   [terraform-provider-gsuite] plugin 0.1.x if GSuite functionality is desired

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
Account in the Seed Project, grant the necessary roles to the Seed Service
Account, and enable the necessary API's in the Seed Project.  Run it as follows:

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
      version = "~> 1.20"
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
      version = "~> 1.20"
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

Be sure you have the correct Terraform version (0.11.x), you can choose the
binary here:

- https://releases.hashicorp.com/terraform/

## Development
### Requirements

- [terraform-docs](https://github.com/segmentio/terraform-docs/releases) 0.3.0
- Ruby 2.3 or greater
- Bundler 1.10 or greater

### File structure

The project has the following folders and files:

- /: root folder
- /examples: examples for using this module
- /scripts: Scripts for specific tasks on module (see Infrastructure section on
  this file)
- /test: Folders with files for testing the module (see Testing section on this
  file)
- /helpers: Optional helper scripts for ease of use
- /main.tf: main file for this module, contains all the resources to create
- /variables.tf: all the variables for the module
- /output.tf: the outputs of the module
- /readme.md: this file

### Integration testing

Integration tests are run though
[test-kitchen](https://github.com/test-kitchen/test-kitchen),
[kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform), and
[InSpec](https://github.com/inspec/inspec).

Two test-kitchen instances are defined:

- `full-local` - Test coverage for all project-factory features.
- `full-minimal` - Test coverage for a minimal set of project-factory features.

#### Setup

1. Configure the [test fixtures](#test-configuration).
2. Download a Service Account key with the necessary [permissions](#permissions)
   and put it in the module's root directory with the name `credentials.json`.
3. Add appropriate variables to your environment

   ```
   export BILLING_ACCOUNT_ID="YOUR_BILLUNG_ACCOUNT"
   export DOMAIN="YOUR_DOMAIN"
   export FOLDER_ID="YOUR_FOLDER_ID"
   export GROUP_NAME="YOUR_GROUP_NAME"
   export ADMIN_ACCOUNT_EMAIL="YOUR_ADMIN_ACCOUNT_EMAIL"
   export ORG_ID="YOUR_ORG_ID"
   export PROJECT_ID="YOUR_PROJECT_ID"
   CREDENTIALS_FILE="credentials.json"
   export SERVICE_ACCOUNT_JSON=`cat ${CREDENTIALS_FILE}`
   ```

4. Run the testing container in interactive mode.
    ```
    make docker_run
    ```

    The module root directory will be loaded into the Docker container at `/cft/workdir/`.
5. Run kitchen-terraform to test the infrastructure.

    1. `kitchen create` creates Terraform state.
    2. `kitchen converge` creates the underlying resources. You can run `kitchen converge minimal` to only create the minimal fixture.
    3. `kitchen verify` tests the created infrastructure. Run `kitchen verify minimal` to run the smaller test suite.
    4. `kitchen destroy` removes the created infrastructure. Run `kitchen destroy minimal` to remove the smaller test suite.

Alternatively, you can simply run `make test_integration_docker` to run all the
test steps non-interactively.

#### Test configuration

Each test-kitchen instance is configured with a `terraform.tfvars` file in the
test fixture directory. For convenience, these are symlinked to a single shared file:

```sh
cp "test/fixtures/shared/terraform.tfvars.example" \
  "test/fixtures/shared/terraform.tfvars"
$EDITOR "test/fixtures/shared/terraform.tfvars"
done
```

Integration tests can be run within a pre-configured docker container. Tests can
be run without user interaction for quick validation, or with user interaction
during development.

### Autogeneration of documentation from .tf files

Run
```
make generate_docs
```

### Linting

The makefile in this project will lint or sometimes just format any shell,
Python, golang, Terraform, or Dockerfiles. The linters will only be run if the
makefile finds files with the appropriate file extension.

All of the linter checks are in the default make target, so you just have to run

```
make -s
```

The -s is for 'silent'. Successful output looks like this

```
Running shellcheck
Running flake8
Running gofmt
Running terraform validate
Running hadolint on Dockerfiles
Test passed - Verified all file Apache 2 headers
```

The linters
are as follows:
* Shell - shellcheck. Can be found in homebrew
* Python - flake8. Can be installed with 'pip install flake8'
* Golang - gofmt. gofmt comes with the standard golang installation. golang
is a compiled language so there is no standard linter.
* Terraform - terraform has a built-in linter in the 'terraform validate'
command.
* Dockerfiles - hadolint. Can be found in homebrew

## Releasing New Versions

New versions can be released by pushing tags to this repository's origin on
GitHub. There is a Make target to facilitate the process:

```
make release-new-version
```

The new version must be documented in [CHANGELOG.md](CHANGELOG.md) for the
target to work.

See the Terraform documentation for more info on [releasing new
versions][release-new-version].

[gsuite-enabled-module]: modules/gsuite_enabled/README.md
[preconditions-checker-script]: modules/core_project_factory/scripts/preconditions/preconditions.py
[terraform-provider-google]: https://github.com/terraform-providers/terraform-provider-google
[terraform-provider-google-beta]: https://github.com/terraform-providers/terraform-provider-google-beta
[terraform-provider-gsuite]: https://github.com/DeviaVir/terraform-provider-gsuite
[glossary]: /docs/GLOSSARY.md
[release-new-version]: https://www.terraform.io/docs/registry/modules/publish.html#releasing-new-versions
[application-default-credentials]: https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application

[2.4.1]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/2.4.1
[terraform-0.12-upgrade]: https://www.terraform.io/upgrade-guides/0-12.html
