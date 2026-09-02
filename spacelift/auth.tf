# Worker auth (managed out-of-band — intentionally not in Terraform):
#
# The worker pods run as arn:aws:iam::355433853014:role/spacelift-role. That same role is
# mapped into the dvtl815-poc EKS cluster's access entries in spacelift-infra
# (var.spacelift_worker_role_arn -> aws_eks_access_entry.spacelift_worker), which is what
# grants cluster access. The k8s/helm get-token in ../providers.tf uses no --role-arn, so the
# worker's *ambient* identity is what reaches the cluster; for that to work it must equal the
# mapped role. Confirm the live identity with:
#   aws sts get-caller-identity   (expect .../spacelift-role)
#
# The IAM role and its Spacelift-OIDC trust policy are created outside Terraform. The worker
# pool Secret (token + privateKey, see workerpool.tf) is likewise applied by hand, to keep the
# private key out of tofu state.
# TODO: scope the role's permissions down before any non-PoC use.
