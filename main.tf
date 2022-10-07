terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "3.5.0"
    }
    
  }

 backend "gcs" {
      bucket = "tf-state-rnd"
      prefix = "terraform/state"
  }

}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.project
  region = var.region
  zone = var.zone
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-netowrk"
    
}


