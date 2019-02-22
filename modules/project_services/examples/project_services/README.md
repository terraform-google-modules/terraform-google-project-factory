# Project Services

This example illustrates how to use the project_services submodule to activate APIs

Expected variables:
- `credentials_path`
- `project_id`

[^]: (autogen_docs_start)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| credentials_path | Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials. | string | `` | no |
| project_id | The GCP project you want to enable APIs on | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| project_id | The GCP project you want to enable APIs on |

[^]: (autogen_docs_end)