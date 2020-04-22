# Upgrading to Project Factory v8.0

The v8.0 release of Project Factory updates the `gcloud` module to use the [1.0.0](https://github.com/terraform-google-modules/terraform-google-gcloud/blob/master/CHANGELOG.md#100-2020-04-15) version.

## gcloud module
If you are relying on the built-in gcloud module, you will need to make sure `curl`
is available in your Terraform execution environment.

If you have `skip_gcloud_download` set to `true`, no change is necessary.
