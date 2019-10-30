# Frequently Asked Questions

## Why am I encountering a low quota with projects created via Terraform?

If you are running the Terraform Project Factory using Service Account credentials, the quota will be based on the
reputation of your service account rather than your user identity. In many cases, this quota is initially low.

If you encounter such quota issues, you should consider opening a support case with Google Cloud to have your quota lifted.

## How should I organize my Terraform structure?

The specific directory structure which works for your organization can vary, but there two principles you should keep in mind:

1. Minimize how many resources are contained in each directory. In general, try to have each directory of Terraform config control no more than a few dozen resources. For the project factory, this means each directory should typically only contain a few projects.

2. Mirror organizational boundaries. It should be very easy for a team to find where their projects are configured, and the easiest way to do this is typically to have the directory structure mirror your organizational structure.

With these principles in mind, this is a structure we've seen organizations successfully implement:

```
Projects Repo
|-- terraform/
|---- config.tf
|---- terraform.tfvars
|---- team1/
|------ config.tf
|------ main.tf
|------ terraform.tfvars
|------ projects.tf
|---- team2/
|---- team3/
```

In this structure, the `config.tf` in the root `terraform/` directory can be symlinked into each of the team directories, as can the `terraform.tfvars` file to store common variables (such as the organization ID). The projects for each team live within that team's `projects.tf` file.

## Where should I store my Terraform state?

We recommend that Terraform state be stored on Google Cloud Storage, using the [gcs backend](https://www.terraform.io/docs/backends/types/gcs.html).

In keeping with the recommended directory structure above, we recommend using a single GCS bucket for the configuration, with separate prefixes for each team. For example:

```hcl
terraform {
  backend "gcs" {
    bucket  = "tf-state-projects"
    prefix  = "terraform/state/team1"
  }
}
```

## Can you expand on why the project factory adds all API Service Accounts to a group?

The purpose of the `api_sa_group` variable is to provide a group where all the [Google-managed service accounts](https://cloud.google.com/iam/docs/service-accounts#google-managed_service_accounts) will automatically be placed for your projects. This is useful to allow them to pull common resources such as shared VM images which products like Managed Instance Groups need access to.

## How do I fork the module?

If you want to modify a module to make customizations, we recommend that you fork it to an internal or external Git repository, with each module getting its own repository.

These forks can then be [referenced directly](https://www.terraform.io/docs/modules/sources.html#generic-git-repository) from Terraform, as follows:

```
module "vpc" {
  source = "git::https://my-git-instance/terraform/terraform-google-project-factory.git"
}
```

## How does the project factory work with a Shared VPC?

The Project Factory supports *attaching* projects to a Shared VPC, while the [Network Factory](https://github.com/terraform-google-modules/terraform-google-network) supports *creating* a shared VPC.

The pattern we encourage is to:

1. Create a Shared VPC host project using the Project Factory
2. Create a shared network in that project using the Network Factory
3. Create additional service projects and attach them to the Shared VPC using the Project Factory

## Why do you delete the default Service Account?

By default, every project comes configured with a [default Service Account](https://cloud.google.com/compute/docs/access/service-accounts#compute_engine_default_service_account). While this Service Account is convenient, it comes with  risks as it automatically has Editor access to your project and is automatically used for gcloud commands or the UI. This can lead to security threats where instances are launched with access they don't need and are compromised.

Therefore, the Project Factory deletes the default Service Account to prevent these risks. In its place, it creates a new Service Account which has a number of advantages:

1. No default roles. This Service Account doesn't have access to any GCP resources unless you explicitly grant them.

2. No default usage. With the default Service Account deleted, you have to be explicit in choosing a Service Account for VMs which ensures developers make an informed choice when deciding what access level to give applications.
