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

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "budget_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name                     = "budget-project-${random_string.suffix.result}"
  random_project_id        = true
  random_project_id_length = 6
  org_id                   = var.org_id
  folder_id                = var.folder_id
  billing_account          = var.billing_account
  budget_amount            = var.budget_amount

  activate_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

}


# An additional budget with more options
resource "google_pubsub_topic" "budget" {
  name    = "budget-topic-${random_string.suffix.result}"
  project = module.budget_project.project_id
}

module "additional_budget" {
  source  = "terraform-google-modules/project-factory/google//modules/budget"
  version = "~> 14.0"

  billing_account        = var.billing_account
  projects               = [var.parent_project_id, module.budget_project.project_id]
  amount                 = var.budget_amount
  display_name           = "CI/CD Budget for ${module.budget_project.project_id}"
  credit_types_treatment = var.budget_credit_types_treatment
  services               = var.budget_services
  alert_spent_percents   = var.budget_alert_spent_percents
  alert_pubsub_topic     = "projects/${module.budget_project.project_id}/topics/${google_pubsub_topic.budget.name}"
  labels = {
    "cost-center" : "dept-x"
  }
}
