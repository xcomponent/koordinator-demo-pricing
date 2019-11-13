provider "kubernetes" {
  version                = "1.9.0"
  host                   = "${var.kubernetes_host}"
  client_certificate = "${base64decode(var.kubernetes_client_certificate)}"
  client_key = "${base64decode(var.kubernetes_client_key)}"
  cluster_ca_certificate = "${base64decode(var.kubernetes_cluster_ca_certificate)}"
  load_config_file       = false
}

resource "kubernetes_pod" "worker_init_pricing" {
  metadata {
    name = "worker-init-pricing"
    namespace = "demo"
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
