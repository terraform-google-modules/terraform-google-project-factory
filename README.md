# Google Cloud Project Factory Terraform Module

This module allows you to create opinionated Google Cloud Platform projects. It creates projects and configures aspects like Shared VPC connectivity, IAM access, Service Accounts, and API enablement to follow best practices.

## Usage
There are multiple examples included in the [examples](./examples/) folder but simple usage is as follows:

```hcl
module "project-factory" {
  source              = "github.com/terraform-google-modules/terraform-google-project-factory?ref=v0.2.0"
  name                = "pf-test-1"
  random_project_id   = "true"
  org_id              = "1234567890"
  usage_bucket_name   = "pf-test-1-usage-report-bucket"
  usage_bucket_prefix = "pf/test/1/integration"
  billing_account     = "ABCDEF-ABCDEF-ABCDEF"
  group_role          = "roles/editor"
  shared_vpc          = "shared_vpc_host_name"
  sa_group            = "test_sa_group@yourdomain.com"
  credentials_path    = "${local.credentials_file_path}"

  shared_vpc_subnets = [
    "projects/base-project-196723/regions/us-east1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/default",
    "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
  ]
}
```

### Features
The Project Factory module will take the following actions:

1. Create a new GCP project using the `project_name`.
1. If a shared VPC is specified, attach the new project to the `shared_vpc`.

    It will also give the following users network access on the specified subnets:

      - The prroject's new default service account (see step 4)
      - The Google API service account for the project
      - The project controlling group specified in `group_name`

1. Delete the default compute service account.
1. Create a new default service account for the project.
    1. Give it access to the shared VPC (to be able to launch instances).
    1. Add it to the `sa_group` in Google Groups, if specified.
1. Attach the billing account (`billing_account`) to the project.
1. Create a new Google Group for the project (`group_name`) if `create_group` is `true`.
1. Give the controlling group access to the project, with the `group_role`.
1. Enable the required and specified APIs (`activate_apis`).
1. Delete the default network.
1. Enable usage report for GCE into central project bucket (`target_usage_bucket`), if provided.
1. If specified, create the GCS bucket `bucket_name` and give the following groups Storage Admin on it:
    1. The controlling group (`group_name`)
    1. The new default compute service account created for the project
    1. The Google APIs service account for the project
1. Add the Google APIs service account to the `api_sa_group` (if specified)

The roles granted are specifically:

- New Default Service Account
  - `compute.networkUser` on host project or specified subnets
  - `storage.admin` on `bucket_name` GCS bucket
  - MEMBER of the specified `sa_group`
- `group_name` is the new controlling group
  - `compute.networkUser` on host project or specific subnets
  - Specified `group_role` on project
  - `iam.serviceAccountUser` on the default Service Account
  - `storage.admin` on `bucket_name` GCS bucket
- Google APIs Service Account
  - `compute.networkUser` on host project or specified subnets
  - `storage.admin` on `bucket_name` GCS bucket
  - MEMBER of the specified `api_sa_group`

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate_apis | The list of apis to activate within the project | list | `<list>` | no |
| api_sa_group | A GSuite group to place the Google APIs Service Account for the project in | string | `` | no |
| app_engine | A map for app engine configuration | map | `<map>` | no |
| auto_create_network | Create the default network | string | `false` | no |
| billing_account | The ID of the billing account to associate this project with | string | - | yes |
| bucket_name | A name for a GCS bucket to create (in the bucket_project project), useful for Terraform state (optional) | string | `` | no |
| bucket_project | A project to create a GCS bucket (bucket_name) in, useful for Terraform state (optional) | string | `` | no |
| create_group | Whether to create the group or not | string | `false` | no |
| credentials_path | Path to a Service Account credentials file with permissions documented in the readme | string | - | yes |
| folder_id | The ID of a folder to host this project | string | `` | no |
| group_name | A group to control the project by being assigned group_role - defaults to ${project_name}-editors | string | `` | no |
| group_role | The role to give the controlling group (group_name) over the project (defaults to project editor) | string | `roles/editor` | no |
| labels | Map of labels for project | map | `<map>` | no |
| name | The name for the project | string | - | yes |
| org_id | The organization id for the associated services | string | - | yes |
| random_project_id | Enables project random id generation | string | `false` | no |
| sa_group | A GSuite group to place the default Service Account for the project in | string | `` | no |
| sa_role | A role to give the default Service Account for the project (defaults to none) | string | `` | no |
| shared_vpc | The ID of the host project which hosts the shared VPC | string | `` | no |
| shared_vpc_subnets | List of subnets fully qualified subnet IDs (ie. projects/$project_id/regions/$region/subnetworks/$subnet_id) | list | `<list>` | no |
| usage_bucket_name | Name of a GCS bucket to store GCE usage reports in (optional) | string | `` | no |
| usage_bucket_prefix | Prefix in the GCS bucket to store GCE usage reports in (optional) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_engine_enabled | Whether app engine is enabled |
| domain | The organization's domain |
| group_email | The email of the created GSuite group with group_name |
| project_bucket_self_link | Project's bucket selfLink |
| project_bucket_url | Project's bucket url |
| project_id |  |
| project_number |  |
| service_account_display_name | The display name of the default service account |
| service_account_email | The email of the default service account |
| service_account_id | The id of the default service account |
| service_account_name | The fully-qualified name of the default service account |
| service_account_unique_id | The unique id of the default service account |

[^]: (autogen_docs_end)

## File structure
The project has the following folders and files:

- /: root folder
- /examples: examples for using this module
- /scripts: Scripts for specific tasks on module (see Infrastructure section on this file)
- /test: Folders with files for testing the module (see Testing section on this file)
- /helpers: Optional helper scripts for ease of use
- /main.tf: main file for this module, contains all the resources to create
- /variables.tf: all the variables for the module
- /output.tf: the outputs of the module
- /readme.md: this file

## Requirements
### Terraform plugins
- [Terraform](https://www.terraform.io/downloads.html) 0.10.x
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin v1.8.0
- [terraform-provider-gsuite](https://github.com/DeviaVir/terraform-provider-gsuite) plugin if GSuite functionality is desired

### Permissions
In order to execute this module you must have a Service Account with the following roles:

- roles/resourcemanager.folderViewer on the folder that you want to create the project in
- roles/resourcemanager.organizationViewer on the organization
- roles/resourcemanager.projectCreator on the organization
- roles/billing.user on the organization
- roles/iam.serviceAccountAdmin on the organization
- roles/storage.admin on bucket_project
- If you are using shared VPC:
  - roles/billing.user on the organization
  - roles/compute.xpnAdmin on the organization
  - roles/compute.networkAdmin on the organization
  - roles/browser on the Shared VPC host project
  - roles/resourcemanager.projectIamAdmin on the Shared VPC host project

Additionally, if you want to use the group management functionality included, you must [enable domain delegation](#g-suite).

#### Script Helper
A [helper script](./helpers/setup-sa.sh) is included to automatically grant all the required roles. Run it as follows:

```
./helpers/setup-sa.sh <ORGANIZATION_ID> <HOST_PROJECT_NAME>
```

### APIs
In order to operate the Project Factory, you must activate the following APIs on the base project where the Service Account was created:

- Cloud Resource Manager API - `cloudresourcemanager.googleapis.com`
- Cloud Billing API - `cloudbilling.googleapis.com`
- Identity and Access Management API - `iam.googleapis.com`
- Admin SDK - `admin.googleapis.com`
- Google App Engine Admin API - `appengine.googleapis.com`

## Caveats

### Moving projects from org into a folder

There is currently a bug with moving a project which was originally created at the root of the organization into a folder. The bug and workaround is described [here](https://github.com/terraform-providers/terraform-provider-google/issues/1701), but as a general best practice it is easier to create all projects within folders to start. Moving projects between different folders *is* supported.

## G Suite
The Project Factory module *optionally* includes functionality to manage G Suite groups as part of the project set up process. This functionality can be used to create groups to hold the project owners and place all Service Accounts into groups automatically for easier IAM management. **This functionality is optional and can easily be disabled by deleting the `gsuite_override.tf` file**.

If you do want to use the G Suite functionality, you will need to be an administator in the [Google Admin console](https://support.google.com/a/answer/182076?hl=en). As an admin, you must [enable domain-wide delegation] for the Project Factory Service Account and grant it the following scopes:

- https://www.googleapis.com/auth/admin.directory.group
- https://www.googleapis.com/auth/admin.directory.group.member

## Install
### Terraform
Be sure you have the correct Terraform version (0.10.x), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins
Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-gsuite](https://github.com/DeviaVir/terraform-provider-gsuite) plugin 0.1.0 (there are not compatible releases, you have to compile it from master branch)

See each plugin page for more information about how to compile and use them

### Fast install (optional)
For a fast install, please configure the variables on init_centos.sh or init_debian.sh script in the helpers directory and then launch it.

The script will do:
- Environment variables setting
- Installation of base packages like wget, curl, unzip, gcloud, etc.
- Installation of go 1.9.0
- Installation of Terraform 0.10.x
- Download the terraform-provider-gsuite plugin
- Compile the terraform-provider-gsuite plugin
- Move the terraform-provider-gsuite to the right location

## Development
### Requirements
- [bats](https://github.com/sstephenson/bats) 0.4.0
- [jq](https://stedolan.github.io/jq/) 1.5
- [terraform-docs](https://github.com/segmentio/terraform-docs/releases) 0.3.0

### Integration testing
The integration tests for this module are built with bats, basically the test checks the following:
- Perform `terraform init` command
- Perform `terraform get` command
- Perform `terraform plan` command and check that it'll create *n* resources, modify 0 resources and delete 0 resources
- Perform `terraform apply -auto-approve` command and check that it has created the *n* resources, modified 0 resources and deleted 0 resources
- Perform several `gcloud` commands and check the infrastructure is in the desired state
- Perform `terraform destroy -force` command and check that it has destroyed the *n* resources

You can use the following command to run the integration test in the folder */test/integration/gcloud-test*

  `. launch.sh`

### Autogeneration of documentation from .tf files
Run
```
make generate_docs
```

### Linting
The makefile in this project will lint or sometimes just format any shell,
Python, golang, Terraform, or Dockerfiles. The linters will only be run if
the makefile finds files with the appropriate file extension.

All of the linter checks are in the default make target, so you just have to
run

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
