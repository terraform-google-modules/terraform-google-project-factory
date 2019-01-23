## 1.0.2

### FIXED

- Fixed deprecation notice for `google-beta` provider in `core_project_factory` module.

## 1.0.1

### FIXED

- Replaced missing forward of `var.disable_services_on_destroy` from `root` module to `core_project_factory` module.

## 1.0.0
1.0.0 is a major backwards incompatible release. See the [upgrade guide](./docs/upgrading_to_project_factory_v1.0.md) for details.

### ADDED
- Support for disable_services_on_destroy flag to leave service active on delete. #91

### CHANGED
- Refactored project factory to eliminate the dependenency on the G Suite provider for all projects. #94

## 0.3.0
### ADDED
- Implement billing account role.
- Remove `CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE`.
- Lien support.

### FIXED
- Fix/refactor `helpers/init_debian.sh`.

## 0.2.1
### ADDED
- Explicit dependency on `google_project_service`.

## 0.2.0
### ADDED
- Make IAM bindings non-authoritative.

## 0.1.0
### ADDED
- This is the initial release of the Project Factory Module.
