resource "google_app_engine_application" "app" {
  count = "${var.enabled ? 1 : 0}"

  project = "${var.project_id}"

  location_id      = "${var.location_id}"
  auth_domain      = "${var.auth_domain}"
  serving_status   = "${var.serving_status}"
  feature_settings = "${var.feature_settings}"
}
