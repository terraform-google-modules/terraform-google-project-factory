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

locals {
  consumer_quotas = { for index, quota in var.consumer_quotas : "${quota.service}-${quota.metric}" => quota }
}

resource "google_service_usage_consumer_quota_override" "override" {
  provider = google-beta
  for_each = local.consumer_quotas

  project        = var.project_id
  service        = each.value.service
  metric         = each.value.metric
  limit          = each.value.limit
  dimensions     = each.value.dimensions
  override_value = each.value.value
  force          = true
}
