variable "region" {
  description = "The region to be set on the providers."
}

data "google_compute_zones" "available" {
    region = "${var.region}"
}


provider "google" {
//  credentials = "${file("~/.config/gcloud/terraform-g5search.json")}"
  region      = "${var.region}"
  zone        = "${data.google_compute_zones.available.names[0]}"
}

provider "google-beta" {
//  credentials = "${file("~/.config/gcloud/terraform-g5search.json")}"
  region      = "${var.region}"
  zone        = "${data.google_compute_zones.available.names[0]}"
}



