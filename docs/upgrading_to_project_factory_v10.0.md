# Upgrading to Project Factory v10.0

The v10.0 release of Project Factory is a backwards incompatible release for
all modules since the breaking change is on
[core_project_factory](../modules/core_project_factory) module which removes the
need of gcloud and local-execs.

## Migration Instructions

1. Make sure you're in the desired state by running terraform plan. It should
   return nothing to change.
1. List all gcloud resources.

   ```shell
   terraform state list | grep project-factory.module.gcloud | sed 's/\[.*$//' | uniq
   ```

   You're going to see something similar to the following.

   ```
   module.project-factory.module.project-factory.module.gcloud_delete.random_id.cache
   module.project-factory.module.project-factory.module.gcloud_deprivilege.random_id.cache
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.decompress
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.decompress_destroy
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.download_gcloud
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.download_jq
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.prepare_cache
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.run_command
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.upgrade
   module.project-factory.module.project-factory.module.gcloud_disable.null_resource.upgrade_destroy
   module.project-factory.module.project-factory.module.gcloud_disable.random_id.cache
   ```

1. Double check the items and when you're sure there's nothing else other than
   project-factory module resources, remove them from the state.

   ```shell
   terraform state list | grep project-factory.module.gcloud | sed 's/\[.*$//' | uniq | xargs terraform state rm
   ```

   If you are not in a Unix system, you will have to delete line by line.

1. Remove the last two items remaining in the state file.
   ```sh
   terraform state rm module.project-factory.module.project-factory.data.null_data_source.default_service_account
   terraform state rm module.project-factory.module.project-factory.null_resource.preconditions
   ```

### Upgrade to provider 3.47

The new resource which replaces the gcloud commands is only available on version
3.47 of Google's terraform provider. So, make sure you relax the version range
or set it to 3.47. Finally, run terraform apply.

```diff
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.project-factory.module.project-factory.google_project_default_service_accounts.default_service_accounts will be created
  + resource "google_project_default_service_accounts" "default_service_accounts" {
      + action           = "DISABLE"
      + id               = (known after apply)
      + project          = "pf-test-1-2db9"
      + restore_policy   = "REVERT"
      + service_accounts = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

It is okay to create the resource since the API does not return error if you try
to disable a disabled service account or delete a deleted service account.
