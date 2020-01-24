resource "kubernetes_config_map" "scenario" {
  metadata {
    name      = "demo-pricing-scenario"
    namespace = var.kubernetes_namespace
    labels = {
      App  = "demo",
      Demo = "pricing"
    }
  }

  binary_data = {
    "scenario.json" = "${filebase64("${path.module}/scenario/scenario.json")}"
  }
}

resource "kubernetes_job" "install_scenario" {
  metadata {
    name      = "install-scenario"
    namespace = var.kubernetes_namespace
    labels = {
      App  = "demo",
      Demo = "pricing"
    }
  }
  spec {
    backoff_limit = 10
    template {
      metadata {}
      spec {
        container {
          name  = "runner"
          image = "curlimages/curl:7.67.0"
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
            name       = "config-volume"
            mount_path = "/opt/demo/config/"
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.scenario.metadata[0].name

          }
        }
      }
    }
  }
}
