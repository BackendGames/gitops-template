terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/civo/terraform.tfstate"
    endpoint = "https://objectstore.<CLOUD_REGION>.civo.com"

    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
     hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.19.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.1.2"
    }
  }
}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  kube_config_filename = "../../../kubeconfig"
}

resource "civo_network" "kubefirst" {
  label = local.cluster_name
}

resource "civo_firewall" "kubefirst" {
  name                 = local.cluster_name
  network_id           = civo_network.kubefirst.id
  create_default_rules = true
}

resource "civo_kubernetes_cluster" "kubefirst" {
  name         = local.cluster_name
  network_id   = civo_network.kubefirst.id
  firewall_id  = civo_firewall.kubefirst.id
  cluster_type = "talos"
  pools {
    label      = local.cluster_name
    size       = "<NODE_TYPE>"
    node_count = tonumber("<NODE_COUNT>") # tonumber() is used for a string token value
  }
}

resource "local_file" "kubeconfig" {
  content  = civo_kubernetes_cluster.kubefirst.kubeconfig
  filename = local.kube_config_filename
}

 # Enable etcd snapshot backups to S3 storage.
  # Just provide a map with the needed settings (according to your S3 storage provider) and backups to S3 will
  # be enabled (with the default settings for etcd snapshots).
  # Cloudflare's R2 offers 10GB, 10 million reads and 1 million writes per month for free.
  # For proper context, have a look at https://docs.k3s.io/datastore/backup-restore.
  # etcd_s3_backup = {
  #   etcd-s3-endpoint        = "xxxx.r2.cloudflarestorage.com"
  #   etcd-s3-access-key      = "<access-key>"
  #   etcd-s3-secret-key      = "<secret-key>"
  #   etcd-s3-bucket          = "k3s-etcd-snapshots"
  # }