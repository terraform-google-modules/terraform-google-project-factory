# Project with tags

This example illustrates two ways to attach resource manager tags to a project:

- **`tags`** — applied atomically at project creation via `google_project.tags`. Use this
  when GOVERN\_TAGS org policies enforce `requireTag*` constraints that check for tags at
  creation time. **Create-only**: changing this map forces project replacement.
- **`tag_binding_values`** — applied post-creation via `google_tags_tag_binding`. Mutable;
  safe to add or remove without replacing the project.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `any` | n/a | yes |
| folder\_id | The ID of a folder to host this project. | `string` | `null` | no |
| organization\_id | The organization id for the associated services | `string` | `"684124036889"` | no |
| project\_tags | Resource manager tags to apply atomically at project creation. Map of tagKeys/\<id\> (or \<parent\>/\<key\_short\>) to tagValues/\<id\> (or \<key\>/\<value\_short\>). Required when GOVERN\_TAGS org policies enforce requireTag\* constraints at creation time. | `map(string)` | `{}` | no |
| tag\_value | Tag value ID (numeric part of tagValues/\<id\>) to bind post-creation via google\_tags\_tag\_binding. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The ID of the created project |
| project\_num | The number of the created project |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
