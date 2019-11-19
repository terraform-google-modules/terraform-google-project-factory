# Upgrading to the Fabric Project module v5.0

**This document only applies to the `fabric-project` module. If you use the main module or other submodules, you can stop reading now.**

The v5.0 release of the `fabric-project` module is a backwards incompatible release, changing how Google Project Services (APIs) are managed.

## Migration instructions

First, ensure there are no pending changes to infrastructure by applying existing code.

```shell
terraform apply
```

Backup Terraform state for safety.

```shell
terraform state pull >terraform-state.json
```

Update the `fabric-project` version to 5.0.0, run `terraform init`, then identify project service resources to move.

```shell
tf state list |grep module.project_services.google_project_service | sed 's/\[.*$//' |uniq
```

The command will output a list of resources which will need to be moved in Terraform state:

```
module.audit-project.module.project_services.google_project_service.project_services
module.service-project.module.project_services.google_project_service.project_services
```

For each of the above resources, issue a `terraform state mv` command, where the destination resource omits `module.project_services`. Using the example above:

```shell
terraform state mv \
  module.audit-project.module.project_services.google_project_service.project_services \
  module.audit-project.google_project_service.project_services
terraform state mv \
  module.service-project.module.project_services.google_project_service.project_services \
  module.service-project.google_project_service.project_services
```

Once done, test that `terraform plan` won't create or destroy any `google_project_service` resource, then delete the `terraform-state.json` file you saved earlier.

In case of issues, revert the module version, run `terraform init`, then revert to the known working Terraform state version with `terraform state push terraform-state.json`.
