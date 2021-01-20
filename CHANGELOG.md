# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Extending the adopted spec, each change should have a link to its corresponding pull request appended.

## [10.1.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v10.0.1...v10.1.0) (2021-01-20)


### Features

* Add labels support to projects bucket ([#534](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/534)) ([67a0b04](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/67a0b045ae013f4c5f410f0103a857789ee5b63a))
* expose grant_services_security_admin_role var ([#536](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/536)) ([c41ba36](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/c41ba360a6bc6800a30d284b8fa23eb3ef5a8d7f))


### Bug Fixes

* Make project service account creation optional ([#528](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/528)) ([4350c5d](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/4350c5d25a5c5bdb4fa09e346e63cc4cf8e9f48f))

### [10.0.1](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v10.0.0...v10.0.1) (2020-12-16)


### Bug Fixes

* Pass service project number for root module ([#496](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/496)) ([#520](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/520)) ([29ff90f](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/29ff90f83c0b1825d0588afe242b25cb7cfb65e8))

## [10.0.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v9.2.0...v10.0.0) (2020-12-15)



### ⚠ BREAKING CHANGES

* Minimum Terraform version increased to 0.13.
* All null_resources for executing gcloud scripts have been removed. See the [upgrade guide](https://github.com/terraform-google-modules/terraform-google-project-factory/blob/master/docs/upgrading_to_project_factory_v10.0.md) for details.
* Renamed the shared_vpc submodule to `svpc_service_project`. [#517](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/517)) ([86819d7](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/86819d74284afa9e13ccf1bad3d18e521a472ff1))


### Features

* add TF 0.13 constraint and module attribution ([#513](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/513)) ([f6df34c](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/f6df34c57abcd94abe44785454c53ce26c9741c4))
* support activate_api_identities in shared_vpc submodule ([#509](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/509)) ([8c5698c](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/8c5698c164d9b03f86cb5ba25d0b3a28a5e1c520))
* **terraform:** Add support Terraform 0.14 by bumping version constraint ([#505](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/505)) ([8c01c41](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/8c01c419849c172ff579a7f0f4b655a9055c9719))


### Bug Fixes

* Add billingbudgets.googleapis.com to precondition script. ([#493](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/493)) ([f9b53c3](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/f9b53c34425790cf95d8912db113956f2d5406ec))
* Add count variable to does not create the resource when value is keep ([#498](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/498)) ([a3deaad](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/a3deaad77881a09e73104984124cdd0740a09e8f))
* Add shared_vpc features back to rood module ([#446](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/446)) ([0a6b9b9](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/0a6b9b9b6226484cba16a210f429817fd0d03aed))
* All dependencies on gcloud have been removed. ([#491](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/491)) ([5886a4e](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/5886a4e4430f551266710d6f635860963be6a4ec))
* readme link to svpc example ([#515](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/515)) ([ce1d46e](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/ce1d46e8ab9d9b895254c3c86b89437045875121))
* Remove whitespace in test/setup-sa ([#495](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/495)) ([6d90ff3](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/6d90ff3869ab390fd3945c222db82c6abe44a456))
* Support passing service project number to shared_vpc_access to be Terraform 0.13 compatible ([#500](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/500)) ([825d07b](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/825d07b19417827d6ad66f9a8dd437b53de32bbc))

## [9.2.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v9.1.0...v9.2.0) (2020-10-16)


### Features

* Add `enable_shared_vpc_host_project` to create project as shared VPC host project ([#465](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/465)) ([3b269be](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/3b269bee7bb7aeda53751fb4d3d5b49b8e41fd6a))
* add apis related outputs to main module ([#470](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/470)) ([abc507f](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/abc507fdd0735ee655c350ce90c58d44816c5779))
* Add budget_monitoring_notification_channels to modules including budgets ([#476](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/476)) ([d1665d1](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/d1665d10e7502eb382bc460a93a59439424c9c19))
* Add impersonate_service_account to shared_vpc module to pass to core_project_factory ([#477](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/477)) ([e9f0c8f](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/e9f0c8fad2ccffac52a9733d91a53320c2d41643))
* Removed preconditions script from Terraform execution ([#478](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/478)) ([79f7c95](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/79f7c953a5267b0d22c2e9396136e27319320ae0))


### Bug Fixes

* Fix Terraform 0.12+ warning on project_services ([#467](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/467)) ([e223f77](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/e223f77bd8510f5459ed4278f23c5b36f64836ee))
* Restore usage of var.enable_apis variable for project services submodule ([#473](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/473)) ([05d1465](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/05d1465d03608310deebb6edde1657d2a50dd0cf))

## [9.1.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v9.0.0...v9.1.0) (2020-09-23)


### Features

* Add budget notification channel ([#456](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/456)) ([9bc317e](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/9bc317e763f767d5666f6876fdae91b3e9a6b200))
* Add Dataflow to Shared VPC API service accounts ([#458](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/458)) ([0c5adf3](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/0c5adf3d147233a41b3480d1b2bd178629e26fae))
* Add service identity provisioning support ([#450](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/450)) ([3954a89](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/3954a898bbc2a9b90852d7c33e57565cb04f14d0))


### Bug Fixes

* Restore shared VPC outputs ([#441](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/441)) ([1b558f3](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/1b558f38f85a75f7cc70f0b89ad25d81cc9ac402)), closes [#438](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/438)
* Upgrade gcloud module to 2.0.0 ([#449](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/449)) ([099cdcc](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/099cdcce28642b045337b4ca0a0c54a9949d9285))

## [9.0.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v8.1.0...v9.0.0) (2020-08-13)


### ⚠ BREAKING CHANGES

* This change requires that you use the `shared_vpc` submodule to manage service account access. See the [upgrade guide](./docs/upgrading_to_project_factory_v9.0.md) for details.

### Features

* Added shared_vpc_access submodule to enable GKE and Dataproc Service Account access. ([#434](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/434)) ([f16fd05](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/f16fd05302179cd2a20485781f3f640a8d5d88ba))


### Bug Fixes

* Fix regression in shared VPC service account submodule ([#438](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/438)) ([dd2dd99](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/dd2dd997650ebea9df220bc750a21a6e813cc962))
* relax version to allow 0.13 ([#437](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/437)) ([9eb64e2](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/9eb64e2217bef8477ae07e1a834c4bfb3f64273f))

## [8.1.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v8.0.2...v8.1.0) (2020-07-22)


### Features

* Add support for attaching projects to a VPC Service Controls perimeter ([#428](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/428)) ([7ec34ef](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/7ec34eff67152466cef1c0ff8f3b303d942bcdda))
* Enable GCS bucket versioning ([#431](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/431)) ([7a0d746](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/7a0d746862199f9345282b831684776b3c77ec7e))


### Bug Fixes

* Add dependency on Shared VPC attachment ([#432](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/432)) ([c954990](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/c9549907429a524d669c6bd5a1b79050dd1e921e))

### [8.0.2](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v8.0.1...v8.0.2) (2020-07-01)


### Bug Fixes

* Correct SA custom name flag check in setup, fixes [#416](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/416) ([#418](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/418)) ([9da8158](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/9da81586f218c13c69f13a4034f606203ac8187c))

### [8.0.1](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v8.0.0...v8.0.1) (2020-05-05)


### Bug Fixes

* Remove appengine.googleapis.com from required APIs ([#390](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/390)) ([b995924](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/b995924d7c33fde1fba029ee3682b7c6252cdd27))

## [8.0.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v7.1.0...v8.0.0) (2020-04-21)


### ⚠ BREAKING CHANGES

* Using the gcloud module now requires `curl` to be installed. See the [upgrade guide](./docs/upgrading_to_project_factory_v8.0.md) for details.

### Bug Fixes

* Bump version of terraform-google-gcloud module to 1.0.0 ([#399](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/399)) ([2889db1](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/2889db19aeb3322d6edf41d7b4aa40f320679650))


### Miscellaneous Chores

* Add upgrade guide for v8.0 ([#401](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/401)) ([dd1e204](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/dd1e204e219ef5f2f8ef14672d40d900036ef75e))

## [7.1.0](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v7.0.2...v7.1.0) (2020-03-17)


### Features

* Add option for skipping the gcloud CLI download ([#393](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/393)) ([a534603](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/a5346030ef36e6982bac05e4e74f56154ab442d6))
* Add use_tf_var_google_credentials_env_var variable ([#377](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/377)) ([64459de](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/64459de4409a64c5cd897cb5bc44eeacc4b67b96))


### Bug Fixes

* Add dependency on service enablement. ([#387](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/387)) ([d3bd3ee](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/d3bd3ee2364d85bb8509b2f697c99f940419213c))

### [7.0.2](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v7.0.1...v7.0.2) (2020-02-23)


### Bug Fixes

* Issue with empty subnet defaults and Shared VPC ([#382](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/382)) ([d31e068](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/d31e06839866d226412f0b4d4b7709bef80d7666))

### [7.0.1](https://www.github.com/terraform-google-modules/terraform-google-project-factory/compare/v7.0.0...v7.0.1) (2020-02-10)


### Bug Fixes

* Allow 3.x provider version in fabric-project submodule. ([#361](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/361)) ([2b32b68](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/2b32b681a8c26be366a173e8d2095da5a66c7de2))
* Allow users to supply dynamically generated list of subnets ([#362](https://www.github.com/terraform-google-modules/terraform-google-project-factory/issues/362)) ([4f372dd](https://www.github.com/terraform-google-modules/terraform-google-project-factory/commit/4f372dd5ca3029b39c293378fea6c1425b5384fc))

## [7.0.0] - 2020-01-15

### Fixed

- Added back `on_failure = continue` to precondition's `local-exec` [#357]

### Added

- The optional `budget_amount` variable will create a budget on the new project. Separate submodule `budget` for additional options. [#354]

### Changed

- **BREAKING**: Addition of `google_billing_budget` increases `google` provider minimum to `>=3.1`. [#354]

## [6.2.1] - 2019-12-18

### Changed

- Changed required `google` provider version to `>= 2.1, < 4.0` [#350]

## [6.2.0] - 2019-12-27

### Added

- The `pip_executable_path` variable which can be altered to support execution in a Windows environment. [#343]
- The `modify-service-account.sh` steps are now executed in the context of the `terraform-google-gcloud` module so there is no longer a dependency on having `gcloud` installed on the host. [#343]

### Fixed

- The precondition script is fixed and will run successfully. `on_failure = "continue"` was also removed to prevent silent failures. [#343]

## [6.1.0] - 2019-12-18

### Added

- The `python_interpreter_path` variable which can be altered to support execution in a Windows environment. [#265]
- Support for importing existing projects. [#138]

### Changed

- When deleting a service account, deprivilege first to remove IAM binding [#341]
- The preconditions script checks for the existence of `gcloud`. [#331]
- The service account setup script only requests the specified project. [#338]

### Fixed

- Fixed typo in `default_service_account` variable's default value from `depriviledge` to `deprivilege`. [#345]
- The `feature_settings` variable on the `app_engine` submodule has a valid default. [#324]

## [6.0.0] - 2019-11-26

6.0.0 is a backwards incompatible release. See the [upgrade guide](./docs/upgrading_to_project_factory_v6.0.md) for details.

### Added

- Option to disable the default compute service account. [#313]

### Changed

- **Breaking**: Default for default compute service account changed to disable from delete. [#313]

### Fixed

- Fixed an issue with passing an empty list to activate_apis. [#300]
- Fixed issues with running project factory requiring org-level permissions. [#320](https://github.com/terraform-google-modules/terraform-google-project-factory/pull/320)

## [5.0.0] - 2019-11-04

5.0.0 is a backwards incompatible release for `modules/fabric-project`. See the [upgrade guide](./docs/upgrading_to_fabric_project_v5.0.md) for details.

### Fixed

- Manage service activation in `modules/fabric-project` with a resource instead of relying on `modules/project-services`, so that output dependency on services works again. Fixes [#308]. [#309]


## [4.0.1] - 2019-10-30

### Fixed

- Add G Suite group name output in G Suite modules. [#288]
- Fix issue with dynamic API activation. [#303]

## [4.0.0] - 2019-10-21
4.0.0 is a major backwards incompatible release. See the [upgrade guide](./docs/upgrading_to_project_factory_v4.0.md) for details.

### Fixed
- Allow impersonating service accounts in G Suite submodule. [#285]
- **Breaking**: Updated service activation to use `for_each` to enable reordering of services safely. [#282]

## [3.3.1] - 2019-10-08

### Fixed

- Make the `custom_roles` output in `modules/fabric-project` v0.12 compliant. [#268]

## [3.3.0] - 2019-09-18

### Fixed

- Allow creation of project_bucket within the project we are creating. [#261]

## [3.2.0] - 2019-08-14

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

- Preconditions script handles projects with a large number of enabled APIs. [#220]

## [2.3.0] - 2019-05-28

### Added

- Feature that toggles authoritative management of project services. [#213]
- Option that provides ability to choose the region of the bucket [#207]
- Added option to deprivilege or keep default compute service account. [#186]

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

[Unreleased]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v7.0.0...HEAD
[7.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v6.2.1...v7.0.0
[6.2.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v6.2.0...v6.2.1
[6.2.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v6.1.0...v6.2.0
[6.1.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v6.0.0...v6.1.0
[6.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v5.0.0...v6.0.0
[5.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v4.0.1...v5.0.0
[4.0.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.3.1...v4.0.0
[3.3.1]: https://github.com/terraform-google-modules/terraform-google-project-factory/compare/v3.3.0...v3.3.1
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

[#357]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/357
[#354]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/354
[#350]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/350
[#343]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/343
[#345]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/345
[#341]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/341
[#338]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/338
[#331]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/331
[#324]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/324
[#313]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/313
[#300]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/300
[#309]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/309
[#308]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/308
[#303]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/303
[#288]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/288
[#282]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/282
[#285]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/285
[#268]: https://github.com/terraform-google-modules/terraform-google-project-factory/pull/268
[#265]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/265
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
[#138]: https://github.com/terraform-google-modules/terraform-google-project-factory/issues/138
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
