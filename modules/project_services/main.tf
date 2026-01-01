/**
 * Copyright 2018 Google LLC
 * ... (License header preserved)
 */

# Get the project data to retrieve the Project Number
data "google_project" "project" {
  project_id = var.project_id
}

locals {
  activate_compute_identity = 0 != length([for i in var.activate_api_identities : i if i.api == "compute.googleapis.com"])
  services                  = var.enable_apis ? toset(concat(var.activate_apis, [for i in var.activate_api_identities : i.api])) : toset([])
  
  service_identities = flatten([
    for i in var.activate_api_identities : [
      for r in i.roles :
      { api = i.api, role = r }
    ]
  ])

  # Deterministic construction of Service Agent emails to avoid 'null' errors.
  # Format: service-PROJECT_NUMBER@gcp-sa-SERVICE_NAME.iam.gserviceaccount.com
  # Note: Compute Engine is the exception as it uses the 'Default Compute Service Account'.
  service_agent_emails = {
    for i in var.activate_api_identities :
    i.api => i.api == "compute.googleapis.com" ? 
      data.google_compute_default_service_account.default[0].email : 
      "service-${data.google_project.project.number}@gcp-sa-${replace(i.api, ".googleapis.com", "")}.iam.gserviceaccount.com"
  }

  add_service_roles = {
    for si in local.service_identities :
    "${si.api} ${si.role}" => {
      email = local.service_agent_emails[si.api]
      role  = si.role
    }
  }
}

/******************************************
  APIs configuration
 *****************************************/
resource "google_project_service" "project_services" {
  for_each                   = local.services
  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services
}

# Still trigger the identity creation to ensure Google actually initializes them.
resource "google_project_service_identity" "project_service_identities" {
  for_each = {
    for i in var.activate_api_identities :
    i.api => i
    if i.api != "compute.googleapis.com"
  }

  provider   = google-beta
  project    = var.project_id
  service    = each.value.api
  depends_on = [google_project_service.project_services]
}

# Handle Compute Engine default account
data "google_compute_default_service_account" "default" {
  count      = local.activate_compute_identity ? 1 : 0
  project    = var.project_id
  depends_on = [google_project_service.project_services]
}

/******************************************
  IAM Roles for Service Identities
 *****************************************/
resource "google_project_iam_member" "project_service_identity_roles" {
  for_each = local.add_service_roles

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"

  # Ensure identity is triggered before we try to assign roles
  depends_on = [
    google_project_service_identity.project_service_identities,
    data.google_compute_default_service_account.default
  ]
}
