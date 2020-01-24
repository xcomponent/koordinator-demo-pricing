resource "kubernetes_deployment" "worker_init_pricing" {
  metadata {
    name = "worker-init-pricing"
    namespace = var.kubernetes_namespace
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  spec {
    selector {
      match_labels = {
        App = "demo",
        Demo = "pricing"
      }
    }
    template {
      metadata {
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
            value   = var.koordinator_token
          }
        }
      }
    }
  }


}

resource "kubernetes_deployment" "pricing_pipeline" {
  metadata {
    name = "worker-pricing-pipeline"
    namespace = var.kubernetes_namespace
    labels = {
      App = "demo",
      Demo = "pricing"
    }
  }

  spec{
    selector {
      match_labels = {
        App = "demo",
        Demo = "pricing"
      }
    }
    template {
      metadata {
        labels = {
          App = "demo",
          Demo = "pricing"
        }
      }
      spec {
        container {
          image = "xcomponentteam/koordinator-demo-pricing:latest"
          name  = "load-pricing-worker"
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
            name = "DEMO_SINGLE_NODE"
            value = "true"
          }
          env {
            name = "DEMO_TOKEN"
            value   = var.koordinator_token
          }
          volume_mount {
            name       = "topics"
            mount_path = "/opt/demo/topics"
          }
        }
        container {
          image = "xcomponentteam/koordinator-demo-pricing:latest"
          name  = "price-worker"
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
            name = "DEMO_SINGLE_NODE"
            value = "true"
          }
          env {
            name = "DEMO_TOKEN"
            value   = var.koordinator_token
          }
          volume_mount {
            name       = "topics"
            mount_path = "/opt/demo/topics"
          }
        }
        volume {
          name = "topics"
          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
  }
}
