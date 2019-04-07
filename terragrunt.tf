################ Providers ################################
variable "region" {
  description = "The region to be set on the providers."
}


provider "google" {
  region      = "${var.region}"
}

provider "google-beta" {
  region      = "${var.region}"
}

################ End of Providers Section #################

################ Backend ##################################
variable "backend_bucket" {}
variable "backend_bucket_prefix" {}

terraform {
  backend "gcs" {
    bucket  = "integrations-tfstate"
    prefix  = "staging/gcp-project/terraform.tfstate"
  }
}


################ End of Providers Section #################




