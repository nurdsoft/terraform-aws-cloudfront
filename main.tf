#-------------------------------------------------------------------------------
# Provider definitions
#-------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

# ------------------------------------------------------------------------------
# CloudFront-scope resources (like WAFv2) must be created in the
# us-east-1 region, regardless of where other resources (e.g., S3) are hosted.
# Defines an aliased provider to explicitly target us-east-1 for those cases.
# ------------------------------------------------------------------------------
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

#-------------------------------------------------------------------------------
# Locals - define a local variable whose value can be re-used multiple times
#-------------------------------------------------------------------------------
locals {
  # When zone_name is provided, construct the FQDN as name.zone_name
  # (e.g. name="mswp", zone_name="nurdsoft.co" → "mswp.nurdsoft.co").
  # When zone_name is omitted, fall back to using name as the full domain
  # for backward compatibility (e.g. name="nurdsoft.co").
  fqdn = var.zone_name != null ? "${var.name}.${var.zone_name}" : var.name

  # This line now checks if the user provided an alias list.
  # If they did, it uses their list. If not, it creates the default two.
  aliases               = var.aliases != null ? var.aliases : [local.fqdn, "www.${local.fqdn}"]
  bucket                = var.s3_bucket_name
  name_iam_role         = "${local.fqdn}-role"
  name_iam_policy_read  = "${local.fqdn}-role-read-policy"
  name_iam_policy_write = "${local.fqdn}-role-write-policy"
  resource_name         = replace(local.fqdn, ".", "-")
}

#-------------------------------------------------------------------------------
# AWS Account ID Lookup
# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
#-------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

#-------------------------------------------------------------------------------
# Create an External ID by generating a random string
#-------------------------------------------------------------------------------
resource "random_string" "external_id" {
  length  = 48
  special = false
  upper   = true
  lower   = true
  numeric = true

  # This block must be set initially otherwise there is no way to regenerate
  # the external ID.
  # To generate a new string, update the corresponding value in the variable.
  # If the value is kept the same, a new string will not be generated when
  # re-running Terraform.
  keepers = {
    generate_new = var.generate_new
  }
}

#-------------------------------------------------------------------------------
# CloudFront Function — SPA directory-index routing (optional)
#-------------------------------------------------------------------------------
resource "aws_cloudfront_function" "spa_routing" {
  count   = var.enable_spa_routing ? 1 : 0
  name    = "${local.resource_name}-spa-routing"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite directory requests to index.html for SPA/static-site routing"
  publish = true
  code    = file("${path.module}/functions/spa-routing.js")
}

#-------------------------------------------------------------------------------
# CloudFront Response Headers Policy for Security
#-------------------------------------------------------------------------------
resource "aws_cloudfront_response_headers_policy" "x_frame_options_policy" {
  name = "${local.resource_name}-x-frame-options-policy"

  security_headers_config {
    frame_options {
      frame_option = var.x_frame_option
      override     = true
    }
  }
}

#-------------------------------------------------------------------------------
# CloudFront Resources
#-------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "cloudfront" {
  aliases             = local.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  tags                = merge(var.tags, { "name" = local.fqdn })

  dynamic "logging_config" {
    for_each = length(keys(var.logging_config)) == 0 ? [] : [var.logging_config]

    content {
      bucket          = logging_config.value["bucket"]
      prefix          = lookup(logging_config.value, "prefix", null)
      include_cookies = lookup(logging_config.value, "include_cookies", null)
    }
  }

  origin {
    # make sure you use the regional bucket name here
    # the CDN is always in the us-east-1 however the bucket we are using is
    # in us-west-2 ... for this to work you need to specify which region the
    # bucket is in. if you do not specify the bucket region ... it takes 24
    # hours for this to propagate to all AWS regions
    # https://aws.amazon.com/premiumsupport/knowledge-center/s3-http-307-response/
    domain_name = aws_s3_bucket.cloudfront.bucket_regional_domain_name
    origin_id   = var.origin_id
    origin_path = var.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods            = var.cache_allowed_methods
    cached_methods             = var.cached_methods
    compress                   = var.cache_compress
    default_ttl                = var.cache_default_ttl
    min_ttl                    = var.cache_min_ttl
    max_ttl                    = var.cache_max_ttl
    target_origin_id           = var.cache_target_origin_id
    viewer_protocol_policy     = var.cache_viewer_proto_policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.x_frame_options_policy.id

    forwarded_values {
      query_string = var.fwd_value_query_string

      cookies {
        forward = var.fwd_value_cookie_fwd
      }
    }

    dynamic "function_association" {
      for_each = var.enable_spa_routing ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.spa_routing[0].arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }

  # restrict access to the distro through a waf
  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  viewer_certificate {
    acm_certificate_arn            = module.acm.acm_certificate_arn
    cloudfront_default_certificate = var.cloudfront_default_certificate
    minimum_protocol_version       = var.viewer_cert_min_proto_version
    ssl_support_method             = var.viewer_cert_ssl_support_method
  }

  custom_error_response {
    error_caching_min_ttl = var.err_cache_min_ttl
    error_code            = var.err_code_one
    response_code         = var.err_resp_code_one
    response_page_path    = var.err_resp_page_path
  }

  # return a 404 on all 403 errors
  # this is related to bucket permissions
  # https://stackoverflow.com/questions/19037664/how-do-i-have-an-s3-bucket-return-404-instead-of-403-for-a-key-that-does-not-exist
  custom_error_response {
    error_caching_min_ttl = var.err_cache_min_ttl
    error_code            = var.err_code_two
    response_code         = var.err_resp_code_two
    response_page_path    = var.err_resp_page_path
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${local.fqdn}-origin-access-identity"
}

#-------------------------------------------------------------------------------
# IAM Resources
#-------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "CloudFrontServiceAccess"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid    = "S3CDNRead"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}",
      ]
    }

    resources = [
      "${aws_s3_bucket.cloudfront.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "custom" {
  count = var.s3_custom_policy != null ? 1 : 0

  source_policy_documents = compact([
    data.aws_iam_policy_document.cloudfront.json,
    var.s3_custom_policy
  ])
}

data "aws_iam_policy_document" "cloudfront_read" {
  statement {
    sid    = "S3Read"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.cloudfront.arn}",
      "${aws_s3_bucket.cloudfront.arn}/*",
    ]
  }

  statement {
    sid    = "ListAllMyBuckets"
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudfrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
      "cloudfront:ListStreamingDistributions",
      "cloudfront:ListDistributions",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudfront_write" {
  statement {
    sid    = "ReadWriteAccess"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.cloudfront.arn}",
      "${aws_s3_bucket.cloudfront.arn}/*",
    ]
  }

  statement {
    sid    = "CloudfrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudfrontFunctionManagement"
    effect = "Allow"

    actions = [
      "cloudfront:CreateFunction",
      "cloudfront:UpdateFunction",
      "cloudfront:DeleteFunction",
      "cloudfront:DescribeFunction",
      "cloudfront:PublishFunction",
      "cloudfront:GetFunction",
      "cloudfront:UpdateDistribution",
      "cloudfront:GetDistributionConfig",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "cloudfront" {
  name               = local.name_iam_role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "cloudfront_read" {
  name        = local.name_iam_policy_read
  description = "A policy that grants the ${local.name_iam_policy_read} access to AWS resources."
  policy      = data.aws_iam_policy_document.cloudfront_read.json
}

resource "aws_iam_policy" "cloudfront_write" {
  name        = local.name_iam_policy_write
  description = "A policy that grants the ${local.name_iam_policy_write} access to AWS resources."
  policy      = data.aws_iam_policy_document.cloudfront_write.json
}

resource "aws_iam_role_policy_attachment" "cloudfront_read" {
  role       = aws_iam_role.cloudfront.name
  policy_arn = aws_iam_policy.cloudfront_read.arn
}

resource "aws_iam_role_policy_attachment" "cloudfront_write" {
  role       = aws_iam_role.cloudfront.name
  policy_arn = aws_iam_policy.cloudfront_write.arn
}

#-------------------------------------------------------------------------------
# WAF for CloudFront must be deployed in us-east-1
#-------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.east
  name     = local.resource_name
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_acl_metric_name
    sampled_requests_enabled   = true
  }
}

#-------------------------------------------------------------------------------
# S3 Resources
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudfront" {
  bucket = local.bucket
  tags   = merge(var.tags, { "name" = local.fqdn })
}

resource "aws_s3_bucket_ownership_controls" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront]
  bucket     = aws_s3_bucket.cloudfront.id
  acl        = var.s3_bucket_acl
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id
  # Use the custom policy if provided, otherwise fall back to the default CloudFront policy
  policy = length(data.aws_iam_policy_document.custom) > 0 ? data.aws_iam_policy_document.custom[0].json : data.aws_iam_policy_document.cloudfront.json
}

resource "aws_s3_bucket_public_access_block" "cloudfront" {
  bucket                  = aws_s3_bucket.cloudfront.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "cloudfront" {
  count  = var.s3_cors_rules != [] && length(var.s3_cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.cloudfront.id
  dynamic "cors_rule" {
    for_each = var.s3_cors_rules
    content {
      id              = try(cors_rule.value["id"], null)
      allowed_methods = cors_rule.value["allowed_methods"]
      allowed_origins = cors_rule.value["allowed_origins"]
      allowed_headers = try(cors_rule.value["allowed_headers"], null)
      expose_headers  = try(cors_rule.value["expose_headers"], null)
      max_age_seconds = try(cors_rule.value["max_age_seconds"], null)
    }
  }
}

#-------------------------------------------------------------------------------
# ACM Certificate and Route53 Validation
#-------------------------------------------------------------------------------

# Data Source to lookup Zone ID automatically

data "aws_route53_zone" "this" {
  name         = var.zone_name != null ? var.zone_name : var.name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.east
  }

  domain_name = local.fqdn
  zone_id     = data.aws_route53_zone.this.zone_id

  # Use the aliases calculated in locals as the SANs
  subject_alternative_names = [for alias in local.aliases : alias if alias != local.fqdn]

  validation_method   = "DNS"
  wait_for_validation = true

  tags = var.tags
}
