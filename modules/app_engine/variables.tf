variable "enabled" {
  description = "Enable App Engine."
  default     = true
}

variable "project_id" {
  description = "The project to enable app engine on."
}

variable "location_id" {
  description = "The location to serve the app from."
  default     = ""
}

variable "auth_domain" {
  description = "The domain to authenticate users with when using App Engine's User API."
  default     = ""
}

variable "serving_status" {
  description = "The serving status of the app."
  default     = "SERVING"
}

variable "feature_settings" {
  description = "A block of optional settings to configure specific App Engine features."
  default     = []
}
