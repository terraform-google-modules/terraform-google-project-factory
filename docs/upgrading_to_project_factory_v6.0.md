# Upgrading to Project Factory v6.0

The v6.0 release of Project Factory is a backwards incompatible release for
new projects only, as it changes how the default compute service account is
treated when the project is created.

The default of `default_service_account` changed from `"delete"` to `"disable"`.
If you want to continue deleting the default compute service account for new
projects, you will need to specify:

```
default_service_account = "delete"
```

## Migration Instructions

Projects that are already created with the default not overridden don't need
any changes, as their service account is already deleted.

Note that changing `default_service_account` to `"disable"` from `"delete"` on
already created projects will not bring the service account back, as the input
is only applied on project creation.
