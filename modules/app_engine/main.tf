/**
 * Copyright 2018 Google LLC
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

resource "google_app_engine_application" "main" {
  project        = var.project_id
  location_id    = var.location_id
  auth_domain    = var.auth_domain
  serving_status = var.serving_status
  dynamic "feature_settings" {
    for_each = var.feature_settings
    content {
      split_health_checks = lookup(feature_settings.value, "split_health_checks", true)
    }
  }
}

