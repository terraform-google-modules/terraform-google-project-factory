# Running preconditions script
This module provides a helper script in order to check if the SEED (project where the GCP Service Account was created) met the requirements to satisfy a project creation needs. For example, check billing account permissions or if certain service API is enabled or not.


# VirtualEnv (Optional)
We recommend running the script inside of a [Python virtual environment](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/) to avoid installing extra packages in your Python default environment.

After installing virtual env by following the link above, create a new Python environment by running:
```
$ python3 -m venv /tmp/preconditions
```
or
```
$ python2 -m virtualenv /tmp/preconditions
```

Finally, activate it:
```
$ source /tmp/preconditions/bin/activate
```

# How to
Do the following steps in order to run preconditions script:

1) Install Python dependencies
    ```
    $ pip install -r helpers/preconditions/requirements.txt
    ```
    <p><b>Note: If you are not running from virtualenv add the suffix --user on each command line</b></p>
1) Execute script
    ```
    $ GOOGLE_CLOUD_PROJECT=my-seed-project python helpers/preconditions/preconditions.py --billing_account [REDACTED] --org_id [REDACTED] --folder_id [REDACTED]
    [
        {
            "type": "Required APIs on service account project",
            "name": "projects/my-seed-project",
            "satisfied": [
                "iam.googleapis.com"
            ],
            "unsatisfied": [
                "admin.googleapis.com",
                "cloudresourcemanager.googleapis.com",
                "cloudbilling.googleapis.com"
            ]
        },
        {
            "type": "Service account permissions on billing account",
            "name": "billingAccounts/[REDACTED]",
            "satisfied": [
                "billing.resourceAssociations.create"
            ],
            "unsatisfied": []
        },
        {
            "type": "Service account permissions on parent folder",
            "name": "folders/[REDACTED]",
            "satisfied": [
                "resourcemanager.projects.create"
            ],
            "unsatisfied": []
        },
        {
            "type": "Service account permissions on organization",
            "name": "organizations/[REDACTED]",
            "satisfied": [],
            "unsatisfied": []
        }
    ]
    ```
    Check #1 (Required APIs on service account project) => It is missing to enable admin, cloudresourcemanager and cloudbilling services APIs in the <b>my-seed-project</b>.

    Check #2 (Service account permissions on billing accoun) => The permission required to associate projects with billing accounts is okay.

    Check #3 (Service account permissions on parent folder) => The permission to create new projects into the folder specified is granted.

    Check #4 (Service account permissions on organization) => No permission required since we are creating the project under the folder instead of the organisation. If no folder is specified it would be step three and require projects.create permission.

    You can add one last check by setting the `--shared-vpc` parameter.
