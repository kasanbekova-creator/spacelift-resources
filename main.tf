resource "kubernetes_namespace" "poc" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "dvtl-815-poc"                 = "true"
      "purpose"                      = "tfc-replacement"
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

resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "7.5.1"

  namespace        = kubernetes_namespace.poc.metadata[0].name
  create_namespace = false

  set = [
    {
      name  = "fullnameOverride"
      value = "spacelift-kube-state-metrics"
    },
    {
      name  = "replicas"
      value = "1"
    },
    {
      name  = "resources.requests.cpu"
      value = "10m"
    },
    {
      name  = "resources.requests.memory"
      value = "32Mi"
    },
    {
      name  = "resources.limits.cpu"
      value = "50m"
    },
    {
      name  = "resources.limits.memory"
      value = "64Mi"
    }
  ]
}
