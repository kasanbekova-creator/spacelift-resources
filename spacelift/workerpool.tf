resource "helm_release" "spacelift_kubernetes_workers" {
  name = "spacelift-workerpool-controller"

  repository = "https://downloads.spacelift.io/helm"
  chart      = "spacelift-workerpool-controller"
  # TODO: pin version (helm list -n spacelift-worker-controller-system)

  namespace        = "spacelift-worker-controller-system"
  create_namespace = true
}

resource "kubernetes_manifest" "worker_pool" {
  manifest = {
    apiVersion = "workers.spacelift.io/v1beta1"
    kind       = "WorkerPool"
    metadata = {
      name      = "test-workerpool"
      namespace = "spacelift-worker-controller-system"
    }
    spec = {
      poolSize   = 2
      token      = { secretKeyRef = { name = "test-workerpool", key = "token" } }
      privateKey = { secretKeyRef = { name = "test-workerpool", key = "privateKey" } }
    }
  }

  depends_on = [helm_release.spacelift_kubernetes_workers]
}

# Secret (token + privateKey) is applied manually to keep the private key out of state.
