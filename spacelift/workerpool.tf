# TODO(spacelift): Kubernetes worker pool via Helm spacelift-workerpool-controller + WorkerPool CRD,
# running as pods inside the private dvtl815-poc cluster.
#
# Steps (confirm with Spacelift reps):
#   1. Add the Spacelift Helm repo and install spacelift-workerpool-controller into a dedicated namespace.
#   2. Create a WorkerPool CRD resource referencing the token/credentials from the Spacelift console.
#   3. Wire the worker pool to the stacks in dvtl-815-infra/ and dvtl-815-resources/.
#
# Resource blocks (helm_release, kubernetes_manifest for WorkerPool CRD) go here once auth
# method is confirmed (see auth.tf).
