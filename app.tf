locals {
  labels = { app = var.app_name }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "dvtl-815-poc"                 = "true"
      "purpose"                      = "web-app"
    }
  }

  # Goldilocks stamps these keys post-create; ignore only them to avoid perpetual drift.
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["goldilocks.fairwinds.com/vpa-resource-policy"],
      metadata[0].labels["goldilocks.fairwinds.com/vpa-update-mode"],
    ]
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "hello"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.labels
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name  = "hello"
          image = "${var.app_image}:${var.app_image_tag}"

          # IfNotPresent is safe: tags are immutable git SHAs, and every deploy carries a new tag.
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "25m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          # readiness gates traffic; liveness restarts a wedged pod. Both hit /healthz.
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.labels

    port {
      port        = var.app_service_port
      target_port = var.app_container_port
      protocol    = "TCP"
    }
  }
}

# Consumes the pre-existing AWS Load Balancer Controller; the alb IngressClass is a pre-existing object (no depends_on).
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-alb"
    namespace = kubernetes_namespace.app.metadata[0].name

    # external-dns-scope=private selects the private-zone controller.
    labels = {
      "external-dns-scope" = "private"
    }

    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/subnets"         = var.app_alb_subnet_ids
      "external-dns.alpha.kubernetes.io/hostname" = var.app_hostname

      # Reference the *validation* resource's arn so the Ingress waits until the cert is ISSUED.
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate_validation.app.certificate_arn

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.app_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = var.app_service_port
              }
            }
          }
        }
      }
    }
  }
}
