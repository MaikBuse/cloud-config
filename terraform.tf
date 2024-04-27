terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "MaikBuse"

    workspaces {
      name = "cloud-config"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
