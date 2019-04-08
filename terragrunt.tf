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

################ Backend Section ##########################
terraform {
  backend "gcs" {}
}

################ End of Backend Section ###################




