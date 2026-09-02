# TEMPORARY: surfaces the identity the Spacelift worker actually runs as, so we can
# confirm which IAM role poc-worker assumes vs what the EKS access entry maps.
# Read during plan (like the other data.aws_* reads), so it works even though
# .spacelift/config.yml hooks are being ignored. DELETE once auth is confirmed.
data "aws_caller_identity" "runner" {}

output "runner_identity_arn" {
  value = data.aws_caller_identity.runner.arn
}
