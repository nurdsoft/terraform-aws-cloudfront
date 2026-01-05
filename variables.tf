#-------------------------------------------------------------------------------
# Provider Variables
#-------------------------------------------------------------------------------
variable "region" {
  description = "The AWS region in which services are provisioned."
  type        = string
  default     = "us-east-1"
}

#-------------------------------------------------------------------------------
# Random String Variables
#-------------------------------------------------------------------------------
variable "generate_new" {
  description = "A random string to use for the External ID."
  type        = string
  default     = "something random but known"
}

#-------------------------------------------------------------------------------
# CloudFront Variables
#-------------------------------------------------------------------------------
variable "aliases" {
  description = <<DESC
Extra CNAMEs (alternate domain names), if any, for this distribution. At this
time you can specify up to 100 CNAMEs separated with commas.
DESC
  type        = list(string)
  default     = null
}

variable "cache_allowed_methods" {
  description = <<DESC
Controls which HTTP methods CloudFront processes and forwards to your Amazon S3
bucket or your custom origin.
DESC
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cache_compress" {
  description = <<DESC
Whether you want CloudFront to automatically compress content for web requests
that include Accept-Encoding: gzip in the request header.
DESC
  type        = bool
  default     = true
}

variable "cache_default_ttl" {
  description = <<DESC
The default amount of time (in seconds) that an object is in a CloudFront cache
before CloudFront forwards another request in the absence of an Cache-Control
max-age or Expires header.
DESC
  type        = number
  default     = 3600
}

variable "cache_min_ttl" {
  description = <<DESC
The minimum amount of time that you want objects to stay in CloudFront caches
before CloudFront queries your origin to see whether the object has been
updated.
DESC
  type        = number
  default     = 3600
}

variable "cache_max_ttl" {
  description = <<DESC
The maximum amount of time (in seconds) that an object is in a CloudFront cache
before CloudFront forwards another request to your origin to determine whether
the object has been updated. Only effective in the presence of Cache-Control
max-age, Cache-Control s-maxage, and Expires headers.
DESC
  type        = number
  default     = 3600
}

variable "cached_methods" {
  description = <<DESC
Controls whether CloudFront caches the response to requests using the specified
HTTP methods.
DESC
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cache_target_origin_id" {
  description = <<DESC
The value of ID for the origin that you want CloudFront to route requests to
when a request matches the path pattern either for a cache behavior or for the
default cache behavior.
DESC
  type        = string
  default     = "S3Origin"
}

variable "cache_viewer_proto_policy" {
  description = <<DESC
Use this element to specify the protocol that users can use to access the files
in the origin specified by TargetOriginId when a request matches the path
pattern in PathPattern. Options: allow-all, https-only, or redirect-to-https.
DESC
  type        = string
  default     = "redirect-to-https"
}

variable "cloudfront_default_certificate" {
  description = <<DESC
Set this to true if you want viewers to use HTTPS to request your objects and
you're using the CloudFront domain name for your distribution. This should be
specified in addition to  acm_certificate_arn, or iam_certificate_id.
DESC
  type        = bool
  default     = false
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}

variable "default_name" {
  description = "The default name for the CloudFront distribution."
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = <<DESC
The object that you want CloudFront to return (for example, index.html) when an
end user requests the root URL.
DESC
  type        = string
  default     = "index.html"
}

variable "name" {
  description = "The application/website name. E.g., foo in foo.bar.com."
  type        = string
  default     = ""
}

variable "endpoint" {
  description = "Used to create a custom DNS record for the distribution."
  type        = string
  default     = ""
}

variable "enabled" {
  description = <<DESC
Whether the distribution is enabled to accept end user requests for content.
DESC
  type        = bool
  default     = true
}

variable "err_code_one" {
  description = "The 4xx or 5xx HTTP status code that should be returned."
  type        = number
  default     = 404
}

variable "err_code_two" {
  description = "The 4xx or 5xx HTTP status code that should be returned."
  type        = number
  default     = 403
}

variable "err_resp_code_one" {
  description = <<DESC
The HTTP status code that you want CloudFront to return with the custom error
page to the viewer.
DESC
  type        = number
  default     = 200
}

variable "err_resp_code_two" {
  description = <<DESC
The HTTP status code that you want CloudFront to return with the custom error
page to the viewer.
DESC
  type        = number
  default     = 200
}

variable "err_resp_page_path" {
  description = "The path of the custom error page."
  type        = string
  default     = "/index.html"
}

variable "fwd_value_query_string" {
  description = <<DESC
Indicates whether you want CloudFront to forward query strings to the origin
that is associated with this cache behavior.
DESC
  type        = bool
  default     = true
}

variable "fwd_value_cookie_fwd" {
  description = <<DESC
Specifies whether you want CloudFront to forward cookies to the origin that is
associated with this cache behavior. You can specify all, none or whitelist. If
whitelist, you must include the subsequent whitelisted_names.
DESC
  type        = string
  default     = "none"
}

variable "http_version" {
  description = <<DESC
The maximum HTTP version to support on the distribution. Allowed values are
http1.1, http2, http2and3 and http3.
DESC
  type        = string
  default     = "http2"
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}

variable "logging_config" {
  description = <<DESC
The logging configuration that controls how logs are written to your 
distribution (maximum one).
DESC
  type        = any
  default     = {}
}

variable "origin_id" {
  description = "A unique identifier for the origin."
  type        = string
  default     = "S3Origin"
}

variable "origin_path" {
  description = <<DESC
A unique identifier for the origin path. This assumes that the directory 
structure is the following s3_bucket_name/current is the cloudfront origin path 
and /backups is the location of the tar.gz backup file for the deployment.
DESC
  type        = string
  default     = ""
}

variable "price_class" {
  description = <<DESC
The price class for this distribution. Options: PriceClass_All, PriceClass_200,
PriceClass_100.
DESC
  type        = string
  default     = "PriceClass_All"
}

variable "restriction_type" {
  description = <<DESC
The method that you want to use to restrict distribution of your content by
country. Options: none, whitelist, or blacklist.
DESC
  type        = string
  default     = "none"
}

variable "viewer_cert_min_proto_version" {
  description = <<DESC
The minimum version of the SSL protocol that you want CloudFront to use for 
HTTPS connections. Can only be set if cloudfront_default_certificate = false. 
See all possible values in this table under "Security policy." Some examples 
include: TLSv1.2_2019 and TLSv1.2_2021. Default: TLSv1. NOTE: If you are using a 
custom certificate (specified with acm_certificate_arn or iam_certificate_id), 
and have specified sni-only in ssl_support_method, TLSv1 or later must be 
specified. If you have specified vip in ssl_support_method, only SSLv3 or 
TLSv1 can be specified. If you have specified cloudfront_default_certificate, 
TLSv1 must be specified.
DESC
  type        = string
  default     = "TLSv1.2_2021"
}

variable "viewer_cert_ssl_support_method" {
  description = <<DESC
Specifies how you want CloudFront to serve HTTPS requests. One of vip or
sni-only. Required if you specify acm_certificate_arn or iam_certificate_id.
NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra
charges.
DESC
  type        = string
  default     = "sni-only"
}

variable "err_cache_min_ttl" {
  description = <<DESC
The minimum amount of time (in seconds) you want HTTP error codes to stay in 
CloudFront caches before CloudFront queries your origin to see whether the 
object has been updated.
DESC
  type        = number
  default     = 10
}

#-------------------------------------------------------------------------------
# WAF Variables
#-------------------------------------------------------------------------------
variable "waf_acl_name" {
  description = "The name or description of the web ACL."
  type        = string
  default     = "Allow access from everywhere"
}

variable "waf_acl_metric_name" {
  description = <<DESC
The name or description for the Amazon CloudWatch metric of this web ACL."
DESC
  type        = string
  default     = "AllowAccessFromEverywhere"
}

variable "waf_acl_default_action_type" {
  description = <<DESC
Configuration block with action that you want AWS WAF to take when a request
doesn't match the criteria in any of the rules that are associated with the web
ACL.
DESC
  type        = string
  default     = "ALLOW"
}

#-------------------------------------------------------------------------------
# ACM Variables
#-------------------------------------------------------------------------------
variable "allow_cert_overwrite" {
  description = "Allow creation of r53 record to overwrite an existing record."
  type        = bool
  default     = true
}

variable "domain" {
  description = "The AWS ACM certificate name."
  type        = string
  default     = ""
}

variable "cert_validation_method" {
  description = "The validation method for the ACM cert. Options: DNS or Email."
  type        = string
  default     = "DNS"
}

variable "create_cert_validation" {
  description = <<DESC
Whether to create a certificate validation request. This is useful for
applications that do not follow the <app_name>.disney.com convention. Should be
set to true when creating a new CloudFront distribution but once available, set
this to false.
DESC
  type        = bool
  default     = true
}

#-------------------------------------------------------------------------------
# S3 Variables
#-------------------------------------------------------------------------------
variable "s3_bucket_acl" {
  description = <<DESC
The canned ACL (Access control list) for the bucket. Options are public or
private.
DESC
  type        = string
  default     = "private"
}

variable "s3_bucket_name" {
  description = <<DESC
S3 Bucket Name
DESC
  type        = string
  default     = null
}

variable "s3_cors_rules" {
  description = <<DESC
CORS Rules to be added on the specific S3 bucket.
DESC
  type              = list(object({
    id              = optional(number, null)
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string), null)
    expose_headers  = optional(list(string), null)
    max_age_seconds = optional(number, null)
    
  }))
  default           = []
}

variable "s3_custom_policy" {
  description =<<DESC
A custom bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
DESC
  type        = string
  default     = null
}

#-------------------------------------------------------------------------------
# Route53 Variables
#-------------------------------------------------------------------------------
variable "r53_record_ttl" {
  description = <<DESC
The TTL (time-to-live) of the record in seconds. This is required for non-alias
records.
DESC
  type        = number
  default     = 60
}

variable "r53_record_type" {
  description = <<DESC
The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, 
SOA, SPF, SRV and TXT.
DESC
  type        = string
  default     = "CNAME"
}

variable "r53_zone_private" {
  description = "Whether the Route53 zone is private."
  type        = bool
  default     = false
}

#-------------------------------------------------------------------------------
# Shared Variables
#-------------------------------------------------------------------------------
variable "tags" {
  description = "The default tags to add to a resource."
  type        = map(string)
  default     = {}
}

variable "x_frame_option" {
  description = "X-Frame-Options header value to prevent clickjacking attacks"
  type        = string
  default     = "DENY"
}