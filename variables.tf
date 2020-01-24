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
