terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }

  }

  backend "gcs" {
    bucket = "tf-state-rnd"
    prefix = "terraform/state"
  }

}

provider "google" {
  #credentials = file(var.credentials_file)
  project = var.project
  region  = var.region
  zone    = var.zone


  batching {
    enable_batching = false
    send_after      = "5s"
  }
}

locals {

  json_data_7 = jsondecode(file("./roles.json"))

  helper_list = flatten([for v in local.json_data_7.saroles :
    [for project, role in v.project-role-pairs :
      { "project" = project
        "role"    = role
        acct_id   = v.acct_id
      display_name = v.display_name }
    ]
  ])
}

# Creates a Service Account for each top level in input
resource "google_service_account" "service_accounts_for_each_7" {
  for_each     = { for v in local.json_data_7.saroles : v.acct_id => v.display_name }
  account_id   = each.key
  display_name = each.value
}

resource "google_project_iam_member" "rolebinding" {
  for_each = { for idx, v in local.helper_list : idx => v }
  project  = each.value.project
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.service_accounts_for_each_7[each.value.acct_id].email}"
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-netowrk"

}


