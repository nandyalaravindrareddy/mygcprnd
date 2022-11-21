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

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone


  batching {
    enable_batching = false
    send_after      = "5s"
  }
}

data "http" "fetchiamdata" {
  #url = "http://localhost:8082/iam/fetchSAcctRoles"
  url = "http://india-VPCEA33EN:8082/iam/fetchSAcctRoles"
}

/*module "gcp_defaults" {
  source = "./vaultsecrets"

  path = "gcp"
  gcp_project      = var.project
  gcp_roleset_name = "oauth-role"
  gcp_credentials  = file(var.credentials_file)

  gcp_bindings = [
    {
      resource = "//cloudresourcemanager.googleapis.com/projects/${var.project}"
      roles = [
        "roles/editor"
      ]
    }
  ]
}*/

locals {

  json_data_7 = jsondecode(data.http.fetchiamdata.body)
  #json_data_7 = jsondecode(file("./roles.json"))

  iam_data = flatten([for v in local.json_data_7.saroles :
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
  for_each = { for idx, v in local.iam_data : idx => v }
  project  = each.value.project
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.service_accounts_for_each_7[each.value.acct_id].email}"
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-netowrk"

}


