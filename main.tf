data "aws_route53_zone" "this" {
  name = var.route53_domain
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.subdomain}.${data.aws_route53_zone.this.name}"
}

locals {
  redirect_split = split("://", var.redirect_url)
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  redirect_all_requests_to {
    protocol  = local.redirect_split[0]
    host_name = local.redirect_split[1]
  }
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.id
  name    = "${var.subdomain}.${data.aws_route53_zone.this.name}"
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.this.website_domain
    zone_id                = aws_s3_bucket.this.hosted_zone_id
    evaluate_target_health = true
  }
}
