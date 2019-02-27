# Upgrading to Project Factory v2.0 (from v1.X)

The v2.0 release of Project Factory is a backwards incompatible release. It only affects users who utilize the `app_engine` argument.

## Migration Instructions

### App Engine Argument Changes

Version 1.X of Project Factory used the `app_engine` map variable to configure App Engine:

```hcl
/// @file main.tf
module "project-factory" {
  # ...
  app_engine {
    location_id = "${var.region}"
    auth_domain = "${var.domain}"

    feature_settings = [
      {
        split_health_checks = false
      },
    ]
  }
}
```

Version 2.X of Project Factory uses a new module named `app_engine`:

```hcl
/// @file main.tf
module "project-factory" {
  # ...
}

module "app-engine" {
  source  = "terraform-google-modules/project-factory/google//modules/app_engine"
  version = "~> 2.0"

  project     = "${var.project_id}
  location_id = "${var.region}"
  auth_domain = "${var.domain}"

  feature_settings = [
    {
      split_health_checks = true
    },
  ]
}
```

### App Engine State Import

The new implementation uses the `google_app_engine_application` resource which needs to be imported into the current state (make sure to replace `$YOUR_PROJECT_ID`):

```sh
terraform import module.app-engine.google_app_engine_application.main $YOUR_PROJECT_ID
```

After importing, run `terraform` `plan` and `apply`.

