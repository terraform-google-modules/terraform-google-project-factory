/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_string" "key_suffix" {
  length  = 7
  special = false
  upper   = false
}

resource "google_tags_tag_key" "key" {
  parent      = "organizations/${var.org_id}"
  short_name  = "pf-key-${random_string.key_suffix.result}"
  description = "Sample tag key"
}

resource "google_tags_tag_value" "value" {
  parent      = "tagKeys/${google_tags_tag_key.key.name}"
  short_name  = "sample-val"
  description = "Sample val"
}
