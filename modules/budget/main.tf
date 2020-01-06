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
  display_name  = var.display_name == null ? "Budget For ${var.project_id}" : var.display_name
  pubsub_topics = var.alert_pubsub_topic == null ? [] : [var.alert_pubsub_topic]
}

resource "google_billing_budget" "budget" {
  provider = google-beta
  count    = var.create_budget ? 1 : 0

  billing_account = var.billing_account
  display_name    = local.display_name

  budget_filter {
    projects               = ["projects/${var.project_id}"]
    credit_types_treatment = var.credit_types_treatment
    services               = var.services
  }

  amount {
    specified_amount {
      units = var.amount
    }
  }

  dynamic "threshold_rules" {
    for_each = var.alert_spent_percents
    content {
      threshold_percent = threshold_rules.value
    }
  }

  dynamic "all_updates_rule" {
    for_each = local.pubsub_topics
    content {
      pubsub_topic = all_updates_rule.value
    }
  }
}
