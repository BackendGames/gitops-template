terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/vault/terraform.tfstate"
    endpoint = "https://<HETZNER_STORE_ENDPOINT>"

    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    hcloud = {
      source = "hetzner/hetzner"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

# export HETZNER_TOKEN=$MYTOKEN is set 
provider "hcloud" {
  region = "<CLOUD_REGION>"
  token  = var.hcloud_token
}

provider "vault" {
  skip_tls_verify = "true"
}
