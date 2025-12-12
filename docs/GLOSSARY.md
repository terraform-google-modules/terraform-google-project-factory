# Glossary

Defined terms in the documentation for Project Factory are capitalized and have
specific meaning within the domain of knowledge.

## Seed Project

An existing GCP project with resources, services, and service accounts needed to
create projects with the project factory.

For a minimal working example of a seed project, create a project using the following command in the [Cloud Console](https://console.cloud.google.com/) or the [gcloud CLI](https://cloud.google.com/sdk/gcloud):
```bash
export FOLDER_ID="<YOUR_FOLDER_ID>"
export BILLING_ACCOUNT_ID="<YOUR_BILLING_ACCOUNT_ID>"
export SEED_PROJECT_ID="<YOUR_SEED_PROJECT_ID>"

gcloud projects create "$SEED_PROJECT_ID" \
  --name="$SEED_PROJECT_ID" \
  --folder="$FOLDER_ID"

gcloud billing projects link "$SEED_PROJECT_ID" \
  --billing-account="$BILLING_ACCOUNT_ID"
```

## Seed Service Account

A service account in the **Seed Project** used to create **Target Projects**.
The Seed Service Account has broad access and should be considered a "root
level" account.

## Target Project

One or more projects managed by the Project Factory.
