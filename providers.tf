variable "region" {
  description = "The region to be set on the providers."
}


provider "google" {
  region      = "${var.region}"
}

provider "google-beta" {
  region      = "${var.region}"
}



