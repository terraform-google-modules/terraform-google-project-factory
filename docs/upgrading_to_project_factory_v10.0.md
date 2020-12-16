# Upgrading to Project Factory v10.0

The v10.0 release of Project Factory is a backwards incompatible release for
all modules since the breaking change is on
[core_project_factory](../modules/core_project_factory) module which removes the
need of gcloud and local-execs.

## Migration Instructions

Remove any references to `skip_gcloud_download` and `use_tf_google_credentials_env_var` if applicable.

### Shared VPC Host Project variable
Previously, the [Project Factory module](../README.md) had an input `var.shared_vpc` that took the ID of the host project which hosts the shared VPC. This variable has now been renamed to `var.svpc_host_project_id` in v10.0 of Project Factory for clarity.

```diff
 module "project-factory" {
   source  = "terraform-google-modules/project-factory/google"
-  version = "~> 9.2"
+  version = "~> 10.0"

   name                 = "pf-test-1"
   random_project_id    = "true"
   org_id               = "1234567890"
   usage_bucket_name    = "pf-test-1-usage-report-bucket"
   usage_bucket_prefix  = "pf/test/1/integration"
   billing_account      = "ABCDEF-ABCDEF-ABCDEF"
-  shared_vpc           = "shared_vpc_host_name"
+  svpc_host_project_id = "shared_vpc_host_name"

   shared_vpc_subnets = [
     "projects/base-project-196723/regions/us-east1/subnetworks/default",
     "projects/base-project-196723/regions/us-central1/subnetworks/default",
     "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
   ]
 }
```

### Shared VPC Service Project submodule
The [`svpc_service_project`](../modules/svpc_service_project) submodule performs the same functions as the root module with the addition of assigning the project as a Shared VPC service project. Note that this submodule was previously an internal submodule named `shared_vpc` and has been externalized and renamed in the v10.0 release of Project Factory. See the [submodule documentation](../modules/svpc_service_project) for usage information and [../examples/shared_vpc](../examples/shared_vpc) for a full example.

## Upgrade provider version

The new resource which replaces the gcloud commands is only available on version
3.47 of Google's terraform provider. So, make sure you relax the version range
or set it to 3.47. Finally, run terraform apply.

```diff
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # module.project-factory.module.project-factory.google_project_default_service_accounts.default_service_accounts will be created
  + resource "google_project_default_service_accounts" "default_service_accounts" {
      + action           = "DISABLE"
      + id               = (known after apply)
      + project          = "pf-test-1-6331"
      + restore_policy   = "REVERT"
      + service_accounts = (known after apply)
    }

  # module.project-factory.module.project-factory.null_resource.preconditions will be destroyed
  - resource "null_resource" "preconditions" {
      - id       = "8792279262642897492" -> null
      - triggers = {
          - "billing_account"  = "REDACTED"
          - "credentials_path" = ""
          - "folder_id"        = ""
          - "org_id"           = "REDACTED"
          - "shared_vpc"       = ""
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_delete.random_id.cache will be destroyed
  - resource "random_id" "cache" {
      - b64         = "s0C2TA" -> null
      - b64_std     = "s0C2TA==" -> null
      - b64_url     = "s0C2TA" -> null
      - byte_length = 4 -> null
      - dec         = "3007362636" -> null
      - hex         = "b340b64c" -> null
      - id          = "s0C2TA" -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_deprivilege.random_id.cache will be destroyed
  - resource "random_id" "cache" {
      - b64         = "hPQCIQ" -> null
      - b64_std     = "hPQCIQ==" -> null
      - b64_url     = "hPQCIQ" -> null
      - byte_length = 4 -> null
      - dec         = "2230583841" -> null
      - hex         = "84f40221" -> null
      - id          = "hPQCIQ" -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.decompress[0] will be destroyed
  - resource "null_resource" "decompress" {
      - id       = "4421481963953862822" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "decompress_command"      = "tar -xzf .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk.tar.gz -C .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a && cp .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk/bin/"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "download_gcloud_command" = "curl -sL -o .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-281.0.0-linux-x86_64.tar.gz"
          - "download_jq_command"     = "curl -sL -o .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && chmod +x .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "project_services"        = "pf-test-1-6331"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.decompress_destroy[0] will be destroyed
  - resource "null_resource" "decompress_destroy" {
      - id       = "5873000014534982711" -> null
      - triggers = {
          - "decompress_command" = "tar -xzf .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk.tar.gz -C .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a && cp .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk/bin/"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.download_gcloud[0] will be destroyed
  - resource "null_resource" "download_gcloud" {
      - id       = "8730604705650342734" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "download_gcloud_command" = "curl -sL -o .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-281.0.0-linux-x86_64.tar.gz"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "project_services"        = "pf-test-1-6331"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.download_jq[0] will be destroyed
  - resource "null_resource" "download_jq" {
      - id       = "5384550100564211294" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "download_jq_command"     = "curl -sL -o .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && chmod +x .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/jq"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "project_services"        = "pf-test-1-6331"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.prepare_cache[0] will be destroyed
  - resource "null_resource" "prepare_cache" {
      - id       = "6650067270784592334" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "prepare_cache_command"   = "mkdir .terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a"
          - "project_services"        = "pf-test-1-6331"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.run_command[0] will be destroyed
  - resource "null_resource" "run_command" {
      - id       = "4614340806538524817" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "create_cmd_body"         = <<~EOT
                --project_id='pf-test-1-6331' \
                --sa_id='769221705452-compute@developer.gserviceaccount.com' \
                --credentials_path='' \
                --impersonate-service-account='' \
                --action='disable'
            EOT
          - "create_cmd_entrypoint"   = ".terraform/modules/project-factory/modules/core_project_factory/scripts/modify-service-account.sh"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "destroy_cmd_body"        = "info"
          - "destroy_cmd_entrypoint"  = "gcloud"
          - "gcloud_bin_abs_path"     = "/Users/thiagocarvalho/dev/thiagonache/community/pdsa/.terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk/bin"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "project_services"        = "pf-test-1-6331"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.upgrade[0] will be destroyed
  - resource "null_resource" "upgrade" {
      - id       = "3764618213551542611" -> null
      - triggers = {
          - "activated_apis"          = "compute.googleapis.com"
          - "arguments"               = "bb0200e91aab415a1093a47a1cb2290c"
          - "default_service_account" = "769221705452-compute@developer.gserviceaccount.com"
          - "md5"                     = "8724d44955a417594c942e0101e4fe82"
          - "project_services"        = "pf-test-1-6331"
          - "upgrade_command"         = ".terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk/bin/gcloud components update --quiet"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.null_resource.upgrade_destroy[0] will be destroyed
  - resource "null_resource" "upgrade_destroy" {
      - id       = "1128888759850027996" -> null
      - triggers = {
          - "upgrade_command" = ".terraform/modules/project-factory.project-factory.gcloud_disable/cache/1613618a/google-cloud-sdk/bin/gcloud components update --quiet"
        } -> null
    }

  # module.project-factory.module.project-factory.module.gcloud_disable.random_id.cache will be destroyed
  - resource "random_id" "cache" {
      - b64         = "FhNhig" -> null
      - b64_std     = "FhNhig==" -> null
      - b64_url     = "FhNhig" -> null
      - byte_length = 4 -> null
      - dec         = "370368906" -> null
      - hex         = "1613618a" -> null
      - id          = "FhNhig" -> null
    }

Plan: 1 to add, 0 to change, 12 to destroy.
```

It is okay to create the resource since the API does not return error if you try
to disable a disabled service account or delete a deleted service account.
