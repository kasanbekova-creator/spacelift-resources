output "poc_namespace_name" {
  description = "Name of the namespace created for the PoC."
  value       = kubernetes_namespace.poc.metadata[0].name
}

output "kube_state_metrics_status" {
  description = "Status of the kube-state-metrics Helm release."
  value       = helm_release.kube_state_metrics.status
}

output "app_namespace_name" {
  description = "Name of the namespace the placeholder web app runs in."
  value       = kubernetes_namespace.app.metadata[0].name
}

output "app_name" {
  description = "Name of the app Deployment/Service (handy for a post-apply verification / kubectl check)."
  value       = kubernetes_deployment.app.metadata[0].name
}

output "app_ingress_name" {
  description = "Name of the app Ingress (handy for a post-apply verification / kubectl check)."
  value       = kubernetes_ingress_v1.app.metadata[0].name
}

output "app_ingress_hostname" {
  description = "Internal ALB hostname. Empty until the controller provisions the ALB (populates on a later apply); resolves only inside the VPC, never from a laptop."
  value       = try(kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "app_url" {
  description = "Friendly HTTPS URL for the app (external-dns-private writes this into the private <account-id>.natera.io zone). Resolves in-VPC / over VPN, not from a laptop."
  value       = "https://${var.app_hostname}"
}

output "app_cert_arn" {
  description = "ARN of the issued wildcard ACM certificate (*.<zone>) bound to the app's internal ALB. Sourced from the validation resource, so it is only non-empty once ACM has issued the cert."
  value       = aws_acm_certificate_validation.app.certificate_arn
}

output "app_cert_domain" {
  description = "Wildcard domain the ACM certificate covers (derived from var.app_hostname)."
  value       = local.app_cert_domain
}

output "app_cert_status" {
  description = "ACM certificate status; reads ISSUED once validation completes."
  value       = aws_acm_certificate_validation.app.id != "" ? "ISSUED" : "PENDING_VALIDATION"
}
