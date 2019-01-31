# Google Cloud Project Factory Terraform Module

[FAQ](./docs/FAQ.md) | [Troubleshooting Guide](./docs/TROUBLESHOOTING.md) |
[Glossary][glossary].

This module allows you to create opinionated Google Cloud Platform projects. It
creates projects and configures aspects like Shared VPC connectivity, IAM
access, Service Accounts, and API enablement to follow best practices.

To include G Suite integration for creating groups and adding Service Accounts into groups, use the
[gsuite_enabled module][gsuite-enabled-module].

## Usage

There are multiple examples included in the [examples](./examples/) folder but simple usage is as follows:

```hcl
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 1.0"

  name                = "pf-test-1"
  random_project_id   = "true"
  org_id              = "1234567890"
  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
  billing_account     = "ABCDEF-ABCDEF-ABCDEF"
  shared_vpc          = "shared_vpc_host_name"
  credentials_path    = "${local.credentials_file_path}"

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

[^]: (autogen_docs_start)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The list of apis to activate within the project | list | `<list>` | no |
| app\_engine | A map for app engine configuration | map | `<map>` | no |
| auto\_create\_network | Create the default network | string | `false` | no |
| billing\_account | The ID of the billing account to associate this project with | string | - | yes |
| bucket\_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `` | no |
| bucket\_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `` | no |
| credentials\_path | Path to a Service Account credentials file with permissions documented in the readme | string | `` | no |
| disable\_services\_on\_destroy | Whether project services will be disabled when the resources are destroyed | string | `true` | no |
| domain | The domain name (optional). | string | `` | no |
| folder\_id | The ID of a folder to host this project | string | `` | no |
| group\_name | A group to control the project by being assigned group_role (defaults to project editor) | string | `` | no |
| group\_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `roles/editor` | no |
| labels | Map of labels for project | map | `<map>` | no |
| lien | Add a lien on the project to prevent accidental deletion | string | `false` | no |
| name | The name for the project | string | - | yes |
| org\_id | The organization ID. | string | - | yes |
| random\_project\_id | Enables project random id generation | string | `false` | no |
| sa\_role | A role to give the default Service Account for the project (defaults to none) | string | `` | no |
| shared\_vpc | The ID of the host project which hosts the shared VPC | string | `` | no |
| shared\_vpc\_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list | `<list>` | no |
| usage\_bucket\_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `` | no |
| usage\_bucket\_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_engine\_enabled | Whether app engine is enabled |
| domain | The organization's domain |
| group\_email | The email of the GSuite group with group_name |
| project\_bucket\_self\_link | Project's bucket selfLink |
| project\_bucket\_url | Project's bucket url |
| project\_id | - |
| project\_number | - |
| service\_account\_display\_name | The display name of the default service account |
| service\_account\_email | The email of the default service account |
| service\_account\_id | The id of the default service account |
| service\_account\_name | The fully-qualified name of the default service account |
| service\_account\_unique\_id | The unique id of the default service account |

[^]: (autogen_docs_end)

## Requirements

### Terraform plugins

-   [Terraform](https://www.terraform.io/downloads.html) 0.10.x
-   [terraform-provider-google] plugin 1.19.x
-   [terraform-provider-google-beta] plugin 1.19.x
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
./helpers/setup-sa.sh <ORGANIZATION_ID> <SEED_PROJECT_NAME>
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
  - This is required if you're using the app_engine input

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
3. Build the Docker containers for testing.
    ```
    CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="credentials.json" make docker_build_terraform
    CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="credentials.json" make docker_build_kitchen_terraform
    ```
4. Run the testing container in interactive mode.
    ```
    make docker_run
    ```

    The module root directory will be loaded into the Docker container at `/cftk/workdir/`.
5. Run kitchen-terraform to test the infrastructure.

    1. `kitchen create` creates Terraform state.
    2. `kitchen converge` creates the underlying resources. You can run `kitchen converge minimal` to only create the minimal fixture.
    3. `kitchen verify` tests the created infrastructure. Run `kitchen verify minimal` to run the smaller test suite.

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
