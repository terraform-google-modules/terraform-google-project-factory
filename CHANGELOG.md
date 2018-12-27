## 0.2.2

IMPROVEMENTS:

- Versioning script refactored to perform release.
- Troubleshooting guide added.
- Implement billing account role.
- Start FAQ document.
- Remove `CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE`.
- `help` Make target.
- Lien support.
- Shared VPC config added to full test suite.
- Refactor Docker image builds for testing.
  - Add alpha gcloud components.
  - Default Terraform version 0.11.10.
  - Update google plugin to 1.19.1.
  - Update gsuite plugin to 0.1.10.
  - Default Ruby version 2.5.3.
  - Pin kitchen-terraform gem to ~> 4.1.

BUG FIXES:

- Fix/refactor `helpers/init_debian.sh`.
- Correctly expand relative `credentials_path` attribute.

## 0.2.1

- Test suite refactoring.
- Versioning script.
- Explicit dependency on `google_project_service`.

## 0.2.0

- Make IAM bindings non-authoritative.

## 0.1.0

This is the initial release of the Project Factory Module.
