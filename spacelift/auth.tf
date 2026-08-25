# TODO(spacelift): AWS auth for the worker pool pods.
#
# PRIMARY: OIDC federation (AssumeRoleWithWebIdentity) — worker pods assume an IAM role via
#   Spacelift's OIDC provider, granting S3 state bucket + DynamoDB lock + EKS/ACM/Route53 access.
# FALLBACK: Pod-label -> ServiceAccount -> IRSA / EKS Pod Identity via Kyverno label mutation.
#
# Confirm approach with Spacelift reps before implementing.
# IAM role, trust policy, and inline policy go here once auth method is decided.
