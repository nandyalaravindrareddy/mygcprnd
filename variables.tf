variable "project" {
  
}

variable "credentials_file" {
  
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "vault_token" {
  description = "Set this value using the 'TF_VAR_vault_token' environment variable."
  default = "hvs.26bTpbHVnm8laHEq0w7KKAiA"
}

variable "vault_addr" {
  default = "http://localhost:8200"
}