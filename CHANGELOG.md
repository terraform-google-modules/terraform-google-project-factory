# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Extending the adopted spec, each change should have a link to its corresponding pull request appended.

## [Unreleased]

## [1.1.1] - 2019-02-25
### FIXED
- Drop dependency on `gsuite` provider from core module. [#147]

## [1.1.0] - 2019-02-22
### ADDED
- Preconditions script checks billing account format. [#117]
- Add project_services submodule. [#133]

### FIXED
- Fix race conditions when creating a new G Suite Group. [#141]
- Drop unnecessary permissions checks in preconditions script. [#143]
- Support numeric folder_id and `folders/folder_id` in preconditions script. [#143]

## [1.0.2] - 2019-01-23
### FIXED
- Fixed deprecation notice for `google-beta` provider in `core_project_factory` module. [#104]

## [1.0.1] - 2019-01-22
### FIXED
- Replaced missing forward of `var.disable_services_on_destroy` from `root` module to `core_project_factory` module. [#125]

## [1.0.0] - 2019-01-18
1.0.0 is a major backwards incompatible release. See the [upgrade guide](./docs/upgrading_to_project_factory_v1.0.md) for details.
### ADDED
- Support for disable_services_on_destroy flag to leave service active on delete. [#91]

### CHANGED
- Refactored project factory to eliminate the dependenency on the G Suite provider for all projects. [#94]

## [0.3.0] - 2018-12-27
### ADDED
- Implement billing account role. [#53]
- Remove `CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE`. [#34]
- Lien support. [#64]

### FIXED
- Fix/refactor `helpers/init_debian.sh`. [#69]

## [0.2.1] - 2018-10-10
### ADDED
- Explicit dependency on `google_project_service`. [#42]

## [0.2.0] - 2018-09-06
### ADDED
- Make IAM bindings non-authoritative. [#17]

## 0.1.0
### ADDED
- This is the initial release of the Project Factory Module.

[Unreleased]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.1.0...v0.2.0

[#147]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/147
[#143]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/143
[#141]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/141
[#133]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/133
[#117]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/117
[#104]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/104
[#125]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/125
[#91]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/91
[#94]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/94
[#53]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/53
[#34]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/34
[#64]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/64
[#69]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/69
[#42]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/42
[#17]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/17
