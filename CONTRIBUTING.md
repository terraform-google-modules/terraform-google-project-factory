Please see
https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/main/CONTRIBUTING-module-repos.md.

In addition to those instructions, you will need a few additional environment
variables to run tests:

TODO: check/trim

```bash
export BILLING_ACCOUNT_ID="YOUR_BILLING_ACCOUNT"
export DOMAIN="YOUR_DOMAIN"
export FOLDER_ID="YOUR_FOLDER_ID"
export GROUP_NAME="YOUR_GROUP_NAME"
export ADMIN_ACCOUNT_EMAIL="YOUR_ADMIN_ACCOUNT_EMAIL"
export ORG_ID="YOUR_ORG_ID"
export PROJECT_ID="YOUR_PROJECT_ID"
CREDENTIALS_FILE="credentials.json"
export SERVICE_ACCOUNT_JSON=`cat ${CREDENTIALS_FILE}`
```
