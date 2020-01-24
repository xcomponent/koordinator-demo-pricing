variable "kubernetes_host" {}
variable "kubernetes_client_certificate" {}
variable "kubernetes_client_key" {}
variable "kubernetes_cluster_ca_certificate" {}
variable "kubernetes_namespace" { default = "default" }
variable "koordinator_front" {}
variable "koordinator_token" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "koordinator_aws_lambda_label" {}

provider "archive" {
  version = "1.3.0"
}

provider "aws" {
  version    = "2.35.0"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "kubernetes" {
  version                = "1.9.0"
  host                   = var.kubernetes_host
  client_certificate     = base64decode(var.kubernetes_client_certificate)
  client_key             = base64decode(var.kubernetes_client_key)
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
  load_config_file       = false
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.kubernetes_namespace
  }
}
