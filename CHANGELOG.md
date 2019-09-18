# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Extending the adopted spec, each change should have a link to its corresponding pull request appended.

## [Unreleased]

### [3.3.0] - 2019-09-18

### Fixed

- Allow creation of project_bucket within the project we are creating. [#261]

### [3.2.0] - 2019-08-14

### Added

- Added a [shared_vpc](https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/modules/shared_vpc) submodule which enables the Shared VPC project ID to be a computed value. [#257]

### Changed

- Replace 'parent_type' and 'parent_id' input variables with single parent variable for fabric submodule. [#259]

## [3.1.0] - 2019-08-12

### Added

- Adding support for service account impersonation and short lived tokens. [#246]

## [3.0.0] - 2019-07-12

### Added

- Automatic installation of `preconditions.py` requirements. [#239]

### Changed

- The supported version of Terraform is 0.12. [#237]

### Fixed

- Documentation for setup-sa.sh. [#230]
- `project_id`output depends on `project_services_authority`. [#234]

## [2.4.1] - 2019-06-21

### Fixed

- Propagation of `apis_authority` variable. [#233]

## [2.4.0] - 2019-06-12

### Added

- Cloud Services service account output on Fabric submodule. [#223]

## [2.3.1] - 2019-05-31

### Fixed

- Precoditions script handles projects with a large number of enabled APIs. [#220]

## [2.3.0] - 2019-05-28

### Added

- Feature that toggles authoritative management of project services. [#213]
- Option that provides ability to choose the region of the bucket [#207]
- Added option to depriviledge or keep default compute service account. [#186]

### Fixed

- `credentials_path` is no longer be required for `gsuite_enabled` module. [#205]
- Dependencies on `gcloud` and `jq` are documented. [#203]
- The preconditions script accepts personal credentials. [#212]

## [2.2.1] - 2019-05-15

### Fixed

- Add Fabric [submodule](https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/modules/fabric-project) for simple project creation. [#201]
- Fix module and tests in minimal test suite (group_email). [#200]
- Versions of providers has been fixed for examples/shared_vpc. [#198]
- GCP subnet share conditions not working correctly. [#194]

## [2.2.0] - 2019-05-03

### Added

- The ability to change bucket location. [#170]
- The argument disable_dependent_services and corresponding variable. [#188]

## [2.1.3] - 2019-04-03

### Fixed

- Unconditional check for optional
  `resourcemanager.organization.get` permission in preconditions script.
  [#178]
- The `project_id` output depends on project service activation. [#180]

## [2.1.2] - 2019-04-01

### Fixed

- Error when verifying billing account permissions [#175]

## [2.1.1] - 2019-03-25

### Fixed

- Removed requirement of `roles/resourcemanager.organizationViewer` when `var.domain` is provided. [#172]

## [2.1.0] - 2019-03-11

### ADDED

- The optional `project_id` variable enables a disconnect between the project name and the project ID. [#154]

### FIXED

- Shared VPC IAM bindings. [#164]

## [2.0.0] - 2019-03-05
2.0.0 is a major backwards incompatible release. See the [upgrade guide](./docs/upgrading_to_project_factory_v2.0.md) for details.

### ADDED

- Added separate App Engine module. [#144]
- Support for v2.X of the Google provider and the Google Beta provider.

### REMOVED

- Removed `app_engine` argument (config block).

## [1.2.0] - 2019-03-05

### CHANGED

- The `credentials_path` variable is now optional; Application Default Credentials may be used instead. [#58]

## [1.1.2] - 2019-03-01
### FIXED
- Stabilized `terraform plan` to prevent the default service account resource from being recreated each time. [#153]

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

[Unreleased]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.2.0...HEAD
[3.3.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.1.0...v3.3.0
[3.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.4.1...v3.0.0
[2.4.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.3.1...v2.4.0
[2.3.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.1.3...v2.2.0
[2.1.3]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v0.1.0...v0.2.0

[#261]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/261
[#259]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/259
[#253]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/253
[#246]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/246
[#257]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/257
[#239]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/239
[#237]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/237
[#234]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/234
[#233]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/233
[#230]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/230
[#223]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/223
[#220]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/220
[#213]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/213
[#212]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/212
[#207]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/207
[#205]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/205
[#203]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/203
[#186]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/186
[#201]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/201
[#200]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/200
[#198]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/198
[#194]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/194
[#188]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/188
[#170]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/170
[#180]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/180
[#178]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/178
[#175]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/175
[#172]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/172
[#164]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/164
[#154]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/154
[#153]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/153
[#147]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/147
[#144]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/144
[#143]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/143
[#141]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/141
[#133]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/133
[#117]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/117
[#104]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/104
[#125]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/125
[#91]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/91
[#94]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/94
[#58]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/58
[#53]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/53
[#34]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/34
[#64]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/64
[#69]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/69
[#42]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/42
[#17]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/17
