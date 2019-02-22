# Upgrading to Project Factory v2.0 (from v1.X)

The v2.0 release of Project Factory is a backwards incompatible release. It only affects users who utilize the `app_engine` argument.

## Migration Instructions

### App Engine

These steps are only required if you are currently using the `app_engine` argument.

#### App Engine Argument Changes

The old version of project factory used a single field for configuring App Engine (`app_engine`):

```hcl
/// @file main.tf

module "project-factory" {
  ...
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

The new version of project factory uses granular fields prefixed by `app_engine_`. There is also an additional `app_engine_enabled` argument that needs to be set to true.

```hcl
/// @file main.tf

module "project-factory" {
  ...
  app_engine_enabled     = true
  app_engine_location_id = "${var.region}"
  app_engine_auth_domain = "${var.domain}"

  app_engine_feature_settings = [
    {
      split_health_checks = true
    },
  ]
}
```

#### App Engine State Import

The new implementation uses the `google_app_engine_application` resource which needs to be imported into the current state (make sure to replace `$YOUR_PROJECT_ID`):

```sh
terraform import module.project-factory.module.project-factory.module.app-engine.google_app_engine_application.app $YOUR_PROJECT_ID
```

After importing, you should be good to `terraform` `plan` and `apply`.

