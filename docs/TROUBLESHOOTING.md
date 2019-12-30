# Troubleshooting

## Terminology

See [GLOSSARY.md][glossary].

- - -
## Problems

* [Common issues](#common-issues)
* [Seed Project missing APIs](#seed-project-missing-apis) - The Seed Project is
  missing required APIs.
* [Seed Service Account missing roles](#seed-service-account-missing-roles) - The Seed Service
  Account has insufficient permissions.

- - -
### Common issues

* [Unable to query status of default GCE service
  account](#unable-to-query-status-of-default-gce-service-account)
* [Cannot manage G Suite group
  membership](#cannot-manage-g-suite-group-membership)
* [Cannot deploy App Engine Flex application](#cannot-deploy-app-engine-flex-application)

#### Unable to query status of default GCE service account

When the Project Factory is used with a misconfigured Seed Project, it will
partially generate a new Target Project, fail, and enter a state where it can no
longer generate Target Projects.

**Error message:**

```
Error: Error refreshing state: 1 error(s) occurred:

* module.project-factory.data.google_compute_default_service_account.default: 1
  error(s) occurred:

* module.project-factory.data.google_compute_default_service_account.default:
  data.google_compute_default_service_account.default: Error reading GCE service
  account not found: googleapi: Error 403: Project 449949713944 is not found and
  cannot be used for API calls. If it is recently created, enable Compute Engine
  API by visiting
  https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=449949713944
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured
```

**Cause:**

The Project Factory has generated a new Target Project but could not enable the
`compute.googleapis.com` API. This causes Terraform to get jammed, with the
following causal chain:

1.  `terraform plan` tries to query the default GCE service account.
1.  The query fails because the `compute.googleapis.com` API is not enabled on
    the Target Project.
1.  The `compute.googleapis.com` API is not enabled on the Target Project
    because it does not have an associated billing account.
1.  The Target Project does not have an associated billing account for one of
    the following causes:
    *   The Seed Project does not have the `cloudbilling.googleapis.com` API
        enabled, so Terraform cannot enable billing on the Target Project.
    *   The Seed Service Account does not have the `roles/billing.user` role on
        the associated billing account, and cannot link the Target Project with
        the billing account.

This issue is confusing because the error indicates that the
`compute.googleapis.com` API is disabled on the Target Project, but the absence
of the Google Compute Engine API is a symptom of an issue with configuring
billing, rather than the cause of the issue itself.

**Solution:**

In order to recover the Terraform configuration, the required APIs need to be
enabled on the Seed Project and Target Project.

1.  Enable billing on the Seed Project:
    1.  Enable the `cloudbilling.googleapis.com` API on the Seed Project:
        ```
        # Requires `roles/serviceusage.admin` on $SEED_PROJECT
        gcloud services enable cloudbilling.googleapis.com \
          --project "$SEED_PROJECT"
        ```
    1.  Associate a billing account with the Seed Project:
        ```sh
        # Requires `roles/billing.projectManager` on $SEED_PROJECT and
        # `roles/billing.user` on the billing account
        gcloud alpha billing projects link "$SEED_PROJECT" \
          --billing-account=[billing-account]
        ```
1.  Enable `compute.googleapis.com` on the Target Project:
    ```sh
    # Requires `roles/serviceusage.admin` on $TARGET_PROJECT
    gcloud services enable compute.googleapis.com --project $TARGET_PROJECT
    ```
    This should be run in the context of the Seed Service Account.  You can add
    the Seed Service Account to your list of authentication credentials by
    issuing the following command and importing the Seed Service Account key:
    ```sh
    gcloud auth activate-service-account \
      --key-file=path-to-service-account-credentials.json
    ```

#### Cannot manage G Suite group membership

**Error messages:**

```
Error: Error applying plan:

1 error(s) occurred:

* module.project-factory.gsuite_group.group: 1 error(s) occurred:

* gsuite_group.group: Error creating group: googleapi: Error 403: Not Authorized to access this resource/api, forbidden
```

```
Error: Error applying plan:

1 error(s) occurred:

* module.project-factory.gsuite_group_member.service_account_sa_group_member: 1
  error(s) occurred:

* gsuite_group_member.service_account_sa_group_member: Error creating group
  member: Post
  https://www.googleapis.com/admin/directory/v1/groups/thebo-pf-service-accounts/members?alt=json:
  oauth2: cannot fetch token: 401 Unauthorized
Response: {
 "error" : "unauthorized_client",
 "error_description" : "Client is unauthorized to retrieve access tokens using this method."
}
```

**Cause:**

By default service accounts cannot manage G Suite resources, because the G Suite
directory API requires a user account with admin rights. A service account can
impersonate a user account with admin rights to interact with the directory API,
but the service account has to be granted domain wide delegation rights to
impersonate users, and must be granted OAuth scopes for the functionality it
needs to interact with.

If you encounter a `403: Not Authorized/forbidden`, likely it means you
provided a service account instead of a user account to the
`impersonated_user_email` variable in the `gsuite` provider.

If you encounter a `401: Unauthorized`, likely it is because domain wide
delegation is not granted to the Seed Service Account, and it will fail to
obtain the access token needed to interact with the Directory API and fail.

See the [README G Suite documentation](../README.md#g-suite) for more
information.

**Solution:**

Provide a user account (_not_ a service account) to the `gsuite` provider via
`impersonated_user_email`.

Enable [domain wide
delegation](https://developers.google.com/admin-sdk/directory/v1/guides/delegation)
on the Seed Service Account with the following scopes:

* https://www.googleapis.com/auth/admin.directory.group
* https://www.googleapis.com/auth/admin.directory.group.member

- - -
#### Failed to instantiate provider "gsuite" Incompatible API version

**Error messages:**

When running terraform validate

```
Error: Failed to instantiate provider "gsuite" to obtain schema: Incompatible
API version with plugin. Plugin version: 4, Client versions: [5]
```

**Cause:**

This is likely caused by an older version of the gsuite provider, for example
the 0.1.10 version which is compatible with Terraform 0.11.  Terraform 0.12
produces this error message because of the new plugin API version.


**Solution:**

Replace the old plugin with a version compatible with 0.12 from the [gsuite
provider releases][gsuite-releases].  For example:

```bash
cd ~/.terraform.d/plugins/darwin_amd64
curl -LO https://github.com/DeviaVir/terraform-provider-gsuite/releases/download/v0.1.22/terraform-provider-gsuite_0.1.22_darwin_amd64.zip
unzip terraform-provider-gsuite_0.1.22_darwin_amd64.zip
```

#### Cannot deploy App Engine Flex application

When the Project Factory removes the default compute engine service account, deployments to App Engine Flex will fail.

**Error message:**

```
$ gcloud app deploy --verbosity debug
DEBUG: Running [gcloud.app.deploy] with arguments: [--verbosity: "debug"]
DEBUG: API endpoint: [https://appengine.googleapis.com/], API version: [v1]
Services to deploy:<Paste>

...

Updating service [default] (this may take several minutes)...failed.
DEBUG: (gcloud.app.deploy) Error Response: [13] An internal error occurred while creating a Google Cloud Storage bucket.
Traceback (most recent call last):
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/calliope/cli.py", line 983, in Execute
		resources = calliope_command.Run(cli=self, args=args)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/calliope/backend.py", line 784, in Run
		resources = command_instance.Run(args)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/surface/app/deploy.py", line 90, in Run
		parallel_build=False)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/command_lib/app/deploy_util.py", line 641, in RunDeploy
		ignore_file=args.ignore_file)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/command_lib/app/deploy_util.py", line 431, in Deploy
		extra_config_settings)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/app/appengine_api_client.py", line 208, in DeployService
		poller=done_poller)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/app/operations_util.py", line 314, in WaitForOperation
		sleep_ms=retry_interval)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/util/waiter.py", line 264, in WaitFor
		sleep_ms, _StatusUpdate)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/util/waiter.py", line 326, in PollUntilDone
		sleep_ms=sleep_ms)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/core/util/retry.py", line 229, in RetryOnResult
		if not should_retry(result, state):
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/util/waiter.py", line 320, in _IsNotDone
		return not poller.IsDone(operation)
	File "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/lib/googlecloudsdk/api_lib/app/operations_util.py", line 183, in IsDone
		encoding.MessageToPyValue(operation.error)))
OperationError: Error Response: [13] An internal error occurred while creating a Google Cloud Storage bucket.
ERROR: (gcloud.app.deploy) Error Response: [13] An internal error occurred while creating a Google Cloud Storage bucket.
```

**Cause:**

The `google.appengine.v1.Versions.CreateVersion` API call, made by `gcloud` when running `gcloud app deploy` on a GAE Flex application,
requires that the default compute service account be in place in the project.

**Solution:**

In order to deploy an App Engine Flex application into a project created by Project Factory,
the default service account must not be disabled (as is the default behavior) or deleted. To prevent the
default service account from being deleted, ensure that the `default_service_account` input
is set to either `deprivilege` or `keep`.

- - -
### Seed project missing APIs

The Project Factory requires the following services to be enabled on the Seed
Project. If these APIs are not enabled, the Project Factory may fail to generate
resources, or generate incomplete resources.

A canonical list of required APIs is available in the
[README](../README.md#apis).

* [cloudresourcemanager.googleapis.com](#missing-api-cloudresourcemanagergoogleapiscom)
* [cloudbilling.googleapis.com](#missing-api-cloudbillinggoogleapiscom)
* [iam.googleapis.com](#missing-api-iamgoogleapiscom)
* [appengine.googleapis.com](#missing-appenginegoogleapiscom) (when managing an
  App Engine instance on the Target Project)
* [admin.googleapis.com](#missing-admingoogleapiscom) (when managing G Suite
  groups and group membership)

#### Missing API: `cloudresourcemanager.googleapis.com`

**Error message:**

```
Error: Error refreshing state: 1 error(s) occurred:

* module.project-factory.data.google_organization.org: 1 error(s) occurred:

* module.project-factory.data.google_organization.org:
  data.google_organization.org: Error reading Organization Not Found :
  [organization-id]: googleapi: Error 403: Cloud Resource Manager API has not
  been used in project [seed-project-number] before or it is disabled. Enable it
  by visiting
  https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=[seed-project-number]
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured

```

**Cause:**

The Seed Project does not have the `cloudresourcemanager.googleapis.com` API
enabled. This prevents the Project Factory from looking up the GCP organization.

**Solution:**

* **Option 1:** enable the required API with `gcloud`:
    ```
    # Requires `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    gcloud services enable cloudresourcemanager.googleapis.com
      --project "$SEED_PROJECT"
    ```
* **Option 2:** create a new Seed Service Account and enable the required APIs:
  ```sh
  # requires `roles/resourcemanager.organizationAdmin` on the organization and
  # `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
  ./helpers/setup-sa.sh [organization id] "$SEED_PROJECT"
    ```

#### Missing API: `cloudbilling.googleapis.com`

**Error message:**

```
Error: Error applying plan:

1 error(s) occurred:

* module.project-factory.google_project.project: 1 error(s) occurred:

* google_project.project: Error setting billing account "[billing-account]" for
  project "projects/[target-project-id]": googleapi: Error 403: Cloud Billing
  API has not been used in project [seed-project-number] before or it is
  disabled. Enable it by visiting
  https://console.developers.google.com/apis/api/cloudbilling.googleapis.com/overview?project=[seed-project-number]
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured
```

**Cause:**

The Seed Project does not have the `cloudbilling.googleapis.com` API enabled.
This prevents the Project Factory from enabling APIs that may result in billing
charges, such as the Google Compute Engine API.

**Solution:**

* **Option 1:** enable the required API with `gcloud`:
    ```
    # Requires `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    gcloud services enable cloudbilling.googleapis.com \
      --project "$SEED_PROJECT"
    ```
* **Option 2:** create a new service account and enable the required APIs:
    ```
    # requires `roles/resourcemanager.organizationAdmin` on the organization
    # and `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    ./helpers/setup-sa.sh [organization id] "$SEED_PROJECT"
    ```

**Notes:**

This error will occur *once* when applying a Terraform plan when the Seed
Project does not have the Cloud Billing API enabled. On subsequent Terraform
runs, Terraform will generate an error indicating that the Compute Engine API is
not enabled on the Target Project. Watch out for this!

#### Missing API: `iam.googleapis.com`

**Error message:**
```
Error: Error applying plan:

3 error(s) occurred:

* module.project-factory.null_resource.delete_default_compute_service_account:
  Error running command
  './.terraform/modules/9a383cbc6c7042259f4a632606c52cf4/scripts/delete-service-account.sh
  [target-project-id] ./credentials.json
  449949713944-compute@developer.gserviceaccount.com': exit status 1. Output:
  API [iam.googleapis.com] not enabled on project [[seed-project-number]].
Would you like to enable and retry (this will take a few minutes)? (y/N)?

ERROR: (gcloud.iam.service-accounts.list) User [[service-account]] does not have
permission to access project [[target-project-id]] (or it may not exist):
Identity and Access Management (IAM) API has not been used in project
[seed-project-number] before or it is disabled. Enable it by visiting
https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=[seed-project-number]
then retry. If you enabled this API recently, wait a few minutes for the action
to propagate to our systems and retry.
- '@type': type.googleapis.com/google.rpc.Help
 links:
 - description: Google developers console API activation
   url: https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=[seed-project-number]

* google_service_account.extra_service_account: 1 error(s) occurred:

* google_service_account.extra_service_account: Error creating service account:
  googleapi: Error 403: Identity and Access Management (IAM) API has not been
  used in project [seed-project-number] before or it is disabled. Enable it by
  visiting
  https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=[seed-project-number]
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured

* module.project-factory.google_service_account.default_service_account: 1
  error(s) occurred:

* google_service_account.default_service_account: Error creating service
  account: googleapi: Error 403: Identity and Access Management (IAM) API has
  not been used in project [seed-project-number] before or it is disabled.
  Enable it by visiting
  https://console.developers.google.com/apis/api/iam.googleapis.com/overview?project=[seed-project-number]
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured
```

**Cause:**

The Seed Project does not have the `iam.googleapis.com` API enabled. This
prevents the Project Factory from deleting the default GCE service account and
assigning IAM roles to groups, service accounts, etc.

**Solution:**

* **Option 1:** enable the required API with `gcloud`:
    ```
    # Requires `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    gcloud services enable iam.googleapis.com --project "$SEED_PROJECT"
    ```
* **Option 2:** create a new Seed Service Account and enable the required APIs:
  ```sh
  # requires `roles/resourcemanager.organizationAdmin` on the organization and
  # `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
  ./helpers/setup-sa.sh [organization id] "$SEED_PROJECT"
    ```

#### Missing API: `appengine.googleapis.com`

**Error message:**

```
$ gcloud app describe --project [target-project-id] --format=json

API [appengine.googleapis.com] not enabled on project [[seed-project-number]].
Would you like to enable and retry (this will take a few minutes)?
(y/N)?
ERROR: (gcloud.app.describe) User [[service-account]] does not have permission
to access app [[target-project-id]] (or it may not exist): App Engine Admin API
has not been used in project [seed-project-number] before or it is disabled.
Enable it by visiting
https://console.developers.google.com/apis/api/appengine.googleapis.com/overview?project=[seed-project-number]
then retry. If you enabled this API recently, wait a few minutes for the action
to propagate to our systems and retry.
- '@type': type.googleapis.com/google.rpc.Help
  links:
  - description: Google developers console API activation
    url: https://console.developers.google.com/apis/api/appengine.googleapis.com/overview?project=[seed-project-number]
```

**Cause**:

The App Engine API is not enabled on the Seed Project, which prevents creation
of an App Engine instance on the Target Project.

**Solution:**

* **Option 1:** enable the required API with `gcloud`:
    ```
    # Requires `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    gcloud services enable appengine.googleapis.com --project "$SEED_PROJECT"
    ```
* **Option 2:** create a new Seed Service Account and enable the required APIs:
  ```sh
  # requires `roles/resourcemanager.organizationAdmin` on the organization and
  # `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
  ./helpers/setup-sa.sh [organization id] "$SEED_PROJECT"
    ```

**Notes:**

The absence of the `appengine.googleapis.com` API will not cause Terraform to
fail, but any interactions with the App Engine instance will fail. Once this API
is activated, it might take a few minutes for Terraform to detect that the App
Engine instance is not present and then create it.

#### Missing API: `admin.googleapis.com`

**Error message:**

```
Error: Error applying plan:

1 error(s) occurred:

* module.project-factory.gsuite_group_member.service_account_sa_group_member: 1
  error(s) occurred:

* gsuite_group_member.service_account_sa_group_member: Error creating group
  member: googleapi: Error 403: Access Not Configured. Admin Directory API has
  not been used in project 454152376537 before or it is disabled. Enable it by
  visiting
  https://console.developers.google.com/apis/api/admin.googleapis.com/overview?project=454152376537
  then retry. If you enabled this API recently, wait a few minutes for the
  action to propagate to our systems and retry., accessNotConfigured
```

**Cause:**

The Directory Admin API is not enabled on the Seed Project, which prevents
management of G Suite resources.

See the [README G Suite documentation](../README.md#g-suite) for more
information.

**Solution:**

* **Option 1:** enable the required API with `gcloud`:
    ```
    # Requires `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
    gcloud services enable admin.googleapis.com --project "$SEED_PROJECT"
    ```
* **Option 2:** create a new Seed Service Account and enable the required APIs:
  ```sh
  # requires `roles/resourcemanager.organizationAdmin` on the organization and
  # `roles/serviceusage.serviceUsageAdmin` on $SEED_PROJECT
  ./helpers/setup-sa.sh [organization id] "$SEED_PROJECT"
    ```

- - -
### Seed Service Account missing roles

The Seed Service Account must have the following roles in order to fully create
a Project Factory.

A canonical list of required roles is available in the
[README](../README.md#permissions)

* Organizational roles
    * [roles/resourcemanager.organizationViewer](#missing-org-role-rolesresourcemanagerorganizationviewer)
      - Required for looking up the domain name associated with the GCP
        organization ID.
    * [roles/resourcemanager.projectCreator](#missing-org-role-rolesresourcemanagerprojectcreator)
      - Required for creating GCP projects within the organization.
    * [roles/compute.xpnAdmin](#missing-shared-vpc-roles) (when using a shared
      VPC) - Required for associating the target project with the host VPC.
    * [roles/compute.networkAdmin](#missing-shared-vpc-roles) (when using a
      shared VPC) - Required for managing shared VPC subnetwork IAM policies.
* Shared VPC project roles (when using a shared VPC)
    * [roles/resourcemanager.projectIamAdmin](#missing-shared-vpc-roles) -
      Required for managing shared VPC project IAM policies.
    * [roles/browser](#missing-shared-vpc-roles) - Required for enumerating
      shared VPC resources.
* Billing account roles
    * [roles/billing.user](#missing-roles-billinguserrole) - Required for
      associating the billing account with a project.

#### Missing org role: `roles/resourcemanager.organizationViewer`

**Error message:**

```
* module.project-factory.data.google_organization.org: 1 error(s) occurred:

* module.project-factory.data.google_organization.org:
  data.google_organization.org: Error reading Organization Not Found :
  [organization-id]: googleapi: Error 403: The caller does not have permission,
  forbidden
```

**Cause:**

The Seed Service Account does not have
`roles/resourcemanager.organizationViewer` on the active organization. The
organizationViewer role grants the Seed Service Account the ability to look up
the GCP organization by the organization ID and fetch the associated domain
name.

**Solution:**

Use `helpers/setup-sa.sh` to create a new Seed Service Account with the necessary
roles.

OR

```
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.organizationViewer" \
  --user-output-enabled false
```

#### Missing org role: `roles/resourcemanager.projectCreator`

**Error message:**

```
1 error(s) occurred:

* module.project-factory.google_project.project: 1 error(s) occurred:

* google_project.project: error creating project [target-project-id]
  ([target-project-name]): googleapi: Error 403: User is not authorized.,
  forbidden. If you received a 403 error, make sure you have the
  `roles/resourcemanager.projectCreator` permission
```

**Cause:**

The Seed Service Account does not have `roles/resourcemanager.projectCreator` on
the active organization. The projectCreator role allows the Seed Service Account
to generate new projects within the GCP organization.

**Solution:**

Use `helpers/setup-sa.sh` to create a new Seed Service Account with the necessary
roles.

OR

```
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectCreator" \
  --user-output-enabled false
```

#### Missing Shared VPC roles

**Error message**:

```
Error: Error applying plan:

7 error(s) occurred:

* module.project-factory.google_compute_shared_vpc_service_project.shared_vpc_attachment:
  1 error(s) occurred:

* google_compute_shared_vpc_service_project.shared_vpc_attachment: googleapi:
  Error 403: Required 'resourcemanager.projects.get' permission for
  'projects/[shared-vpc-project-id]', forbidden
* module.project-factory.google_project_iam_member.gke_host_agent: 1 error(s)
  occurred:

* google_project_iam_member.gke_host_agent: Error retrieving IAM policy for
  project "[shared-vpc-project-id]": googleapi: Error 403: The caller does not
  have permission, forbidden
* module.project-factory.google_project_iam_member.controlling_group_vpc_membership[3]:
  1 error(s) occurred:

* google_project_iam_member.controlling_group_vpc_membership.3: Error retrieving
  IAM policy for project "[shared-vpc-project-id]": googleapi: Error 403: The
  caller does not have permission, forbidden
* google_project_iam_member.additive_shared_vpc_role: 1 error(s) occurred:

* google_project_iam_member.additive_shared_vpc_role: Error retrieving IAM
  policy for project "[shared-vpc-project-id]": googleapi: Error 403: The caller
  does not have permission, forbidden
* module.project-factory.google_project_iam_member.controlling_group_vpc_membership[1]:
  1 error(s) occurred:

* google_project_iam_member.controlling_group_vpc_membership.1: Error retrieving
  IAM policy for project "[shared-vpc-project-id]": googleapi: Error 403: The
  caller does not have permission, forbidden
* module.project-factory.google_project_iam_member.controlling_group_vpc_membership[0]:
  1 error(s) occurred:

* google_project_iam_member.controlling_group_vpc_membership.0: Error retrieving
  IAM policy for project "[shared-vpc-project-id]": googleapi: Error 403: The
  caller does not have permission, forbidden
* module.project-factory.google_project_iam_member.controlling_group_vpc_membership[2]:
  1 error(s) occurred:

* google_project_iam_member.controlling_group_vpc_membership.2: Error retrieving
  IAM policy for project "[shared-vpc-project-id]": googleapi: Error 403: The
  caller does not have permission, forbidden
```

**Cause:**

The service account is missing one of the following roles:

* Organization
    * `roles/compute.xpnAdmin`
    * `roles/compute.networkAdmin`
    * `roles/iam.serviceAccountAdmin`
* Shared VPC
    * `roles/browser`
    * `roles/resourcemanager.projectIamAdmin`

These roles are required for associating the Target Project with the host VPC
and managing access to the host VPC network resources.

**Solution:**

Use `helpers/setup-sa.sh` to create a new Seed Service Account with the
necessary roles.

OR

```sh
# Requires `roles/resourcemanager.organizationAdmin` on $ORG_ID
gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.xpnAdmin" \
  --user-output-enabled false

gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin" \
  --user-output-enabled false

gcloud organizations add-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountAdmin" \
  --user-output-enabled false

gcloud projects add-iam-policy-binding \
  "${SHARED_VPC_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --user-output-enabled false

gcloud projects add-iam-policy-binding \
  "${SHARED_VPC_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/browser" \
  --user-output-enabled false
```

#### Missing `roles/billing.user` role

**Error message:**
```
Error: Error applying plan:

1 error(s) occurred:

* module.project-factory.google_project.project: 1 error(s) occurred:

* google_project.project: Error setting billing account "[billing-account]" for
  project "projects/[target-project-id]": googleapi: Error 403: The caller does
  not have permission, forbidden
```

**Cause**:

The Seed Service Account does not have the `roles/billing.user` role on the
billing account, and cannot link projects to the billing account. This will
prevent activation of GCP APIs (such as the Compute Engine API) that may incur
billing charges.

**Solution:**

Add the service account to the `roles/billing.user` role on the billing account.

1. Fetch the billing account IAM policy.
    ```
    # Requires `roles/billing.admin` on the billing account
    $ gcloud beta billing accounts get-iam-policy [billing-account] \
      | tee policy.yml
    bindings:
    - members:
      - group:devs@example.com
      role: roles/billing.admin
    - members:
      - group:billing-users@example.com
      - serviceAccount:[service-account]@[seed-project-id].iam.gserviceaccount.com
      role: roles/billing.user
    etag: BwV3v6LFTjQ=
    ```
1. Update the policy to include the service account.
    ```
    $ $EDITOR policy.yml
    ```
1. Verify that the policy is correct and only affects the service account.
    ```
    $ cat policy.yml
    bindings:
    - members:
      - group:devs@example.com
      role: roles/billing.admin
    - members:
      - group:billing-users@example.com
      - serviceAccount:[service-account]@[seed-project-id].iam.gserviceaccount.com
      role: roles/billing.user
    etag: BwV3v6LFTjQ=
    ```
1. Update the billing account policy.
    ```
    # Requires `roles/billing.admin` on the billing account
    $ gcloud beta billing accounts set-iam-policy [billing-account] policy.yml
    Updated IAM policy for account [[billing-account]].
    ```

**Notes:**

* Granting `roles/billing.user` on the organization is not sufficient if the
  billing account is defined outside of the GCP organization. Make sure that the
Seed Service Account has the `roles/billing.user` role on the billing account.
* If you encounter this error creating an initial project, e.g. using
  `simple_project`, then you will also encounter the [Unable to query status of
  default GCE service
  account](#unable-to-query-status-of-default-gce-service-account) issue on
  subsequent Terraform runs because the GCE API is not enabled.

[glossary]: /docs/GLOSSARY.md
[gsuite-releases]: https://github.com/DeviaVir/terraform-provider-gsuite/releases
