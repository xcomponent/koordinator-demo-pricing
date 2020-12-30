terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "1.3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "2.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.9.0"
    }
  }
}

provider "archive" {
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "kubernetes" {
  host                   = var.kubernetes_host
  client_certificate     = base64decode(var.kubernetes_client_certificate)
  client_key             = base64decode(var.kubernetes_client_key)
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
  load_config_file       = false
}
