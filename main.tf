variable "kubernetes_host" { default = ""}
variable "kubernetes_client_certificate" { default     = "" }
variable "kubernetes_client_key" { default             = "" }
variable "kubernetes_cluster_ca_certificate" { default = "" }
variable "kubernetes_namespace" { default = "demo" }
variable "koordinator_front" { default = "" }
variable "koordinator_token" { default = "" }
variable "aws_access_key" { default = "" }
variable "aws_secret_key" { default = "" }
variable "aws_region" { default = "" }

provider "archive" {
  version = "1.3.0"
}

provider "aws" {
  version = "2.35.0"
  region  = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "kubernetes" {
  version                = "1.9.0"
  host                   = "${var.kubernetes_host}"
  client_certificate = "${base64decode(var.kubernetes_client_certificate)}"
  client_key = "${base64decode(var.kubernetes_client_key)}"
  cluster_ca_certificate = "${base64decode(var.kubernetes_cluster_ca_certificate)}"
  load_config_file       = false
}

resource "kubernetes_config_map" "scenario" {
  metadata {
    name = "demo-pricing-scenario"
    namespace = "${var.kubernetes_namespace}"
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  binary_data = {
    "scenario.json" = "${filebase64("${path.module}/scenario/scenario.json")}"
  }
}

resource "kubernetes_job" "install_scenario" {
  metadata {
    name = "install-scenario"
    namespace = "${var.kubernetes_namespace}"
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "runner"
          image   = "curlimages/curl:7.67.0"
          command = [
            "/usr/bin/curl",
            "-X", "POST",
            "${var.koordinator_front}/workflowsservice/api/scenario-definitions",
            "-H", "Authorization: Bearer ${var.koordinator_token}",
            "-H", "Content-Type: application/json",
            "--data", "@/opt/demo/config/scenario.json",
            "--verbose",
            "--fail"
          ]
          volume_mount {
            name = "config-volume"
            mount_path = "/opt/demo/config/"
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = "${kubernetes_config_map.scenario.metadata[0].name}"

          }
        }
      }
    }
  }
}

resource "kubernetes_pod" "worker_init_pricing" {
  metadata {
    name = "worker-init-pricing"
    namespace = "${var.kubernetes_namespace}"
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  spec {
    container {
      image = "xcomponentteam/koordinator-demo-pricing:latest"
      name  = "worker"
      env {
        name = "SCRIPT_NAME"
        value = "initPricing.js"
      }
      env {
        name = "DEMO_TASK_CATALOG_URL"
        value = "${var.koordinator_front}/taskcatalogservice"
      }
      env {
        name = "DEMO_POLLING_URL"
        value = "${var.koordinator_front}/pollingservice"
      }
      env {
        name = "DEMO_TASK_STATUS_URL"
        value = "${var.koordinator_front}/taskstatusservice"
      }
      env {
        name = "DEMO_TOKEN"
        value   = "${var.koordinator_token}"
      }
    }
  }
}

resource "kubernetes_pod" "worker_load_pricing_context" {
  metadata {
    name = "worker-load-pricing-context"
    namespace = "${var.kubernetes_namespace}"
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  spec {
    container {
      image = "xcomponentteam/koordinator-demo-pricing:latest"
      name  = "worker"
      env {
        name = "SCRIPT_NAME"
        value = "loadPricingContext.js"
      }
      env {
        name = "DEMO_TASK_CATALOG_URL"
        value = "${var.koordinator_front}/taskcatalogservice"
      }
      env {
        name = "DEMO_POLLING_URL"
        value = "${var.koordinator_front}/pollingservice"
      }
      env {
        name = "DEMO_TASK_STATUS_URL"
        value = "${var.koordinator_front}/taskstatusservice"
      }
      env {
        name = "DEMO_TOKEN"
        value   = "${var.koordinator_token}"
      }
    }
  }
}

resource "kubernetes_pod" "worker_price" {
  metadata {
    name = "worker-price"
    namespace = "${var.kubernetes_namespace}"
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  spec {
    container {
      image = "xcomponentteam/koordinator-demo-pricing:latest"
      name  = "worker"
      env {
        name = "SCRIPT_NAME"
        value = "price.js"
      }
      env {
        name = "DEMO_TASK_CATALOG_URL"
        value = "${var.koordinator_front}/taskcatalogservice"
      }
      env {
        name = "DEMO_POLLING_URL"
        value = "${var.koordinator_front}/pollingservice"
      }
      env {
        name = "DEMO_TASK_STATUS_URL"
        value = "${var.koordinator_front}/taskstatusservice"
      }
      env {
        name = "DEMO_TOKEN"
        value   = "${var.koordinator_token}"
      }
    }
  }
}

data "archive_file" "report_lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda/"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "report" {
  filename      = "${data.archive_file.report_lambda.output_path}"
  function_name = "DemoPricing_Report"
  role          = "arn:aws:iam::163696169398:role/S3FullAccess"
  handler       = "index.handler"

  source_code_hash = "${data.archive_file.report_lambda.output_base64sha256 }"

  runtime = "nodejs10.x"
}
