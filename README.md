# Terraform Project Factory

This module handles opinionated Google Cloud Platform project creation and configuration with Shared VPC, IAM, APIs, etc.

## Requirements
### Terraform plugins
- [Terraform](https://www.terraform.io/downloads.html) 0.10.x
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google) plugin v1.8.0
- [terraform-provider-gsuite](https://github.com/DeviaVir/terraform-provider-gsuite) plugin

### Configure a Service Account
In order to execute this module you must have a Service Account with the following:
#### Roles
The service account with the following roles:
- roles/resourcemanager.folderViewer on the folder that you want to create the project in
- roles/resourcemanager.organizationViewer on the organization
- roles/resourcemanager.projectCreator on the organization
- roles/billing.user on the organization
- roles/compute.xpnAdmin on the organization (if using a shared_vpc)
- roles/compute.networkAdmin on the organization
- roles/iam.serviceAccountAdmin on the organization
- roles/browser on the host project (if using a shared_vpc)
- roles/resourcemanager.projectIamAdmin on the host project (if using a shared_vpc)
- roles/storage.admin on bucket_project

#### GSuite domain delegation
- Enable the G Suite Domain-wide Delegation on your service account

#### Usage report
- Give enough permissions to Service Account on the bucket for reading and writing objects.

### Enable API's
In order to operate with the Service Account you must activate the following API's on the base project where the Service Account was created:

- Cloud Resource Manager API - cloudresourcemanager.googleapis.com
- Cloud Billing API - cloudbilling.googleapis.com
- Identity and Access Management API - iam.googleapis.com
- Admin SDK - admin.googleapis.com
- Google App Engine Admin API - appengine.googleapis.com

### GSuite
#### Admin
- You will need an admin on your Google Admin site.

#### API Client access
Give API client access to Service Account on your Google Admin site
- Go to Security > Settings > Advanced Settings > Manage API client access
- Add the client ID of your Service Account and the following scopes:
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

## Fast install (optional)
For a fast install, please configure the variables on init_centos.sh or init_debian.sh script in the helpers directory and then launch it.

The script will do:
- Environment variables setting
- Installation of base packages like wget, curl, unzip, gcloud, etc.
- Installation of go 1.9.0
- Installation of Terraform 0.10.x
- Download the terraform-provider-gsuite plugin
- Compile the terraform-provider-gsuite plugin
- Move the terraform-provider-gsuite to the right location

## Scripted Setting of Permissions on Host Project Service Account (optional)
This will grant the service account in your host project the needed permissions.

To use the script, run the following with the appropriate values:
- `helpers/set-host-sa-permissions.sh <ORGANIZATION_ID> <HOST_PROJECT_NAME> '<SERVICE_ACCOUNT_ID>'`

## Usage
You can go to the examples folder, however the usage of the module could be like this in your own main.tf file:

*Configure the provider here before the module invocation, see the examples folder*

    locals {
          credentials_file_path    = "<PATH TO THE SERVICE ACCOUNT JSON FILE>"
    }

    provider "google" {
      credentials                  = "${file(local.credentials_file_path)}"
  }

    provider "gsuite" {
      credentials                  = "${file(local.credentials_file_path)}"
      impersonated_user_email      = "<YOUR GSUITE ADMIN EMAIL>"
      oauth_scopes = [
        "https://www.googleapis.com/auth/admin.directory.group",
        "https://www.googleapis.com/auth/admin.directory.group.member"
      ]
    }
    module "project-factory" {
      source             = "<PATH TO MODULE>"
      name               = "pf-test-1"
      random_project_id  = "true"
      org_id             = "1234567890"
      usage_bucket_name  = "pf-test-1-usage-report-bucket"
      billing_account    = "ABCDEF-ABCDEF-ABCDEF"
      group_role         = "roles/editor"
      shared_vpc         = "shared_vpc_host_name"
      sa_group           = "test_sa_group@yourdomain.com"
      credentials_path   = "${local.credentials_file_path}"
      shared_vpc_subnets = [
        "projects/base-project-196723/regions/us-east1/subnetworks/default",
        "projects/base-project-196723/regions/us-central1/subnetworks/default",
        "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
      ]
    }

Then perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

#### Variables
Please refer the /variables.tf file for the required and optional variables.

#### Outputs
Please refer the /outputs.tf file for the outputs that you can get with the `terraform output` command

## Infrastructure
The resources/services/activations/deletions that this module will create/trigger are:
- A Google project
- Specified API's activation on the project
- Shared VPC configuration (if provided)
- A default Service Account creation
- Make the Service Account member of your provided `sa_group`
- Deletion of the default compute service (via bash script)
- Deletion of the default network (via bash script)
- Creation of a GSuite group with your provided `group_name` if `created_group` is true
- Storage the usage reports to the specified bucket
- Bucket `bucket_name` creation on `bucket_project`

The roles granted for the specific resources are:
- Service Account
  - compute.networkUser on host project or specific subnets
  - compute.instanceAdmin.v1 on project
  - MEMBER on `sa_group`
  - storage.admin on `bucket_name`

- `group_name`
  - compute.networkUser on host project or specific subnets
  - `group_role` on project
  - iam.serviceAccountUser on Service Account
  - storage.admin on `bucket_name`

- APIs Service Account
  - compute.networkUser on host project or specific subnets
  - MEMBER on `api_sa_group`
  - storage.admin on `bucket_name`

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
- /readme.MD: this file

## Testing

### Requirements
- [bats](https://github.com/sstephenson/bats) 0.4.0
- [jq](https://stedolan.github.io/jq/) 1.5

### Integration test
##### Terraform integration tests
The integration tests for this module are built with bats, basically the test checks the following:
- Perform `terraform init` command
- Perform `terraform get` command
- Perform `terraform plan` command and check that it'll create *n* resources, modify 0 resources and delete 0 resources
- Perform `terraform apply -auto-approve` command and check that it has created the *n* resources, modified 0 resources and deleted 0 resources
- Perform several `gcloud` commands and check the infrastructure is in the desired state
- Perform `terraform destroy -force` command and check that it has destroyed the *n* resources

You can use the following command to run the integration test in the folder */test/integration/gcloud-test*

  `. launch.sh`

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
