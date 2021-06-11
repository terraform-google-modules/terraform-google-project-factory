# Private Catalog

This example demonstrates how a Project Factory can be integrated with [Private Catalog](https://cloud.google.com/private-catalog/docs/terraform-configuration).

## Set up

1. Choose the project you will manage the Private Catalog from.

    export PROJECT_ID="my-project-id"
    gcloud config set project $PROJECT_ID

1. Enable the [required APIs](https://github.com/terraform-google-modules/terraform-google-project-factory#apis) on your management project, including the Cloud Billing API.

    gcloud services enable cloudbuild.googleapis.com cloudresourcemanager.googleapis.com cloudbilling.googleapis.com iam.googleapis.com admin.googleapis.com

1. Grant Cloud Build the necessary roles:

    export CLOUD_BUILD_SA="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')@cloudbuild.gserviceaccount.com"
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/editor"
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/storage.admin"
    gcloud organizations add-iam-policy-binding $ORG_ID \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/billing.user"
    gcloud organizations add-iam-policy-binding $ORG_ID \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/resourcemanager.folderAdmin"
    gcloud organizations add-iam-policy-binding $ORG_ID \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/resourcemanager.organizationViewer"
    gcloud organizations add-iam-policy-binding $ORG_ID \
      --member "serviceAccount:${CLOUD_BUILD_SA}" \
      --condition=None \
      --role "roles/resourcemanager.projectCreator"


1. Create a bucket to...

1. Enable object versioning

      gsutil versioning set on gs://clf-pc-demo

1. Create a zip and upload it to GCS

    zip -r pc.zip *
    gsutil cp pc.zip gs://clf-pc-demo

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| credentials\_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | `string` | `""` | no |
| organization\_id | The organization id for the associated services | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_example | The organization's domain |
| project\_info\_example | The ID of the created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
