locals {
  # Parent zone = app_hostname minus its first label.
  app_dns_zone_name = join(".", slice(split(".", var.app_hostname), 1, length(split(".", var.app_hostname))))
  app_cert_domain   = "*.${local.app_dns_zone_name}"
}

# private_zone=false: an identically named private zone can also exist; pick the public one.
data "aws_route53_zone" "public" {
  name         = local.app_dns_zone_name
  private_zone = false
}

# create_before_destroy: on a SAN/domain change, mint+rebind the new cert before destroying the old (no listener gap).
resource "aws_acm_certificate" "app" {
  domain_name       = local.app_cert_domain
  validation_method = "DNS"

  tags = {
    "dvtl-815-poc" = "true"
    "purpose"      = "app-alb-wildcard"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# for_each over domain_validation_options; allow_overwrite replaces a stale record from a prior attempt.
resource "aws_route53_record" "app_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for r in aws_route53_record.app_cert_validation : r.fqdn]

  # 10m: fail fast on stuck validation rather than using the 75m provider default.
  timeouts {
    create = "10m"
  }
}
