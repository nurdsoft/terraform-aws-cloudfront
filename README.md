# terraform-aws-modules-cloudfront

A project that provides an AWS (Amazon Web Services) CloudFront Terraform module.

## Usage

`Simple CDN with S3 Bucket`:
```hcl
terraform {
  backend "s3" {
    bucket = "aws-shared-terraform-state"
    key    = "aws/use1/modules/cloudfront/simple-cdn-with-s3/terraform.tfstate"
    region = "us-east-1"
  }
}

module "simple-cdn-with-s3" {
  source = "../../"
  # myapp is merely a placeholder. Replace it with actual name.
  name = "myapp.nurdsoft.co"
  tags = {
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
    application_name = "myapp"
  }
}
```

`Simple CDN with Custom S3 Bucket Policy`:

```hcl
terraform {
  backend "s3" {
    bucket = "aws-shared-terraform-state"
    key    = "aws/use1/modules/cloudfront/simple-cdn-with-custom-s3-policy/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  bucket_name = "myapp.nurdsoft.co"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

module "simple-cdn-with-custom-s3-policy" {
  source = "../../"
  name             = local.bucket_name
  s3_custom_policy = data.aws_iam_policy_document.bucket_policy.json
  tags = {
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
    application_name = "myapp"
  }
}
```

## Assumptions

The module assumes the following:

- A basic understanding of [Git](https://git-scm.com/).
- Git version `>= 2.33.0`.
- An existing AWS IAM user or role with access to create/update/delete resources defined in [main.tf](https://github.com/nurdsoft/terraform-aws-modules-cloudfront/blob/main/main.tf).
- An existing AWS Route53 Zone.
  - **Important Note:** This module relies on an existing Route 53 Hosted Zone matching for certificate validation. It will **not** create a new zone if one is not found; the lookup will simply fail.
- A basic understanding of [Terraform](https://www.terraform.io/).
- Terraform version `>= 1.0.2`.
- (Optional - for local testing) A basic understanding of [Make](https://www.gnu.org/software/make/manual/make.html#Introduction).
  - Make version `>= GNU Make 3.81`.
  - **Important Note**: This project includes a [Makefile](https://github.com/nurdsoft/terraform-aws-modules-cloudfront/blob/main/Makefile) to speed up local development in Terraform. The `make` targets act as a wrapper around Terraform commands. As such, `make` has only been tested/verified on **Linux/Mac OS**. Though, it is possible to [install make using Chocolatey](https://community.chocolatey.org/packages/make), we **do not** guarantee this approach as it has not been tested/verified. You may use the commands in the [Makefile](https://github.com/nurdsoft/terraform-aws-modules-cloudfront/blob/main/Makefile) as a guide to run each Terraform command locally on Windows.

## Contributions

Contributions are always welcome. As such, this project uses the `main` branch as the source of truth to track changes.

**Step 1**. Clone this project.
```sh
# Using Git
$ git clone git@github.com:nurdsoft/terraform-aws-modules-cloudfront.git

# Using HTTPS
$ git clone https://github.com/nurdsoft/terraform-aws-modules-cloudfront.git
```

**Step 2**. Checkout a feature branch: `git checkout -b feature/abc`.

**Step 3**. Validate the change/s locally by executing the steps defined under [Test](#test).

**Step 4**. If testing is successful, commit and push the new change/s to the remote.
```sh
$ git add file1 file2 ...

$ git commit -m "Adding some change"

$ git push --set-upstream origin feature/abc
```

**Step 5**. Once pushed, create a [PR](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) and assign it to a member for review.
- **Important Note**: It can be helpful to attach the `terraform plan` output in the PR.

**Step 6**. A team member reviews/approves/merges the change/s.

**Step 7**. Once merged, deploy the required changes as needed.

**Step 8**. Once deployed, verify that the changes have been deployed.


## Test

**Important Note**: This project includes a [Makefile](https://github.com/nurdsoft/terraform-aws-modules-cloudfront/blob/main/Makefile) to speed up local development in Terraform. The `make` targets act as a wrapper around Terraform commands. As such, `make` has only been tested/verified on **Linux/Mac OS**. Though, it is possible to [install make using Chocolatey](https://community.chocolatey.org/packages/make), we **do not** guarantee this approach as it has not been tested/verified. You may use the commands in the [Makefile](https://github.com/nurdsoft/terraform-aws-modules-cloudfront/blob/main/Makefile) as a guide to run each Terraform command locally on Windows.

```sh
# Perform a dry-run on the infrastructure
$ make plan
# Create the infrastructure
$ make apply
# Perform a dry-run on a destroy
$ make plan-destroy
# Destroy the infrastructure
$ make destroy
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.68 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.68 |
| <a name="provider_aws.cert"></a> [aws.cert](#provider\_aws.cert) | ~> 3.68 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_s3_bucket"></a> [aws\_s3\_bucket](#module\_aws\_s3\_bucket) | git@github.com:nurdsoft/terraform-aws-modules-s3 | v0.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_iam_policy.cloudfront_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudfront_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudfront_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudfront_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_waf_web_acl.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_web_acl) | resource |
| [random_string.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudfront_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudfront_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acceleration_status"></a> [acceleration\_status](#input\_acceleration\_status) | Set the acceleration status of an existing bucket. Options are Enabled or<br>Suspended. NOTE: As of 10/15/19, acceleration\_status in not available in the<br>cn-north-1 or us-gov-west-1 regions. | `string` | `"Enabled"` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Extra CNAMEs (alternate domain names), if any, for this distribution. At this<br>time you can specify up to 100 CNAMEs separated with commas. | `list(string)` | `null` | no |
| <a name="input_allow_cert_overwrite"></a> [allow\_cert\_overwrite](#input\_allow\_cert\_overwrite) | Allow creation of r53 record to overwrite an existing record. | `bool` | `true` | no |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket. Enabling this <br>setting does not affect existing policies or ACLs. When set to true causes the <br>following behavior:<br>PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows <br>public access.<br>PUT Object calls will fail if the request includes an object ACL. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. Enabling <br>this setting does not affect the existing bucket policy. When set to true causes <br>Amazon S3 to:<br>Reject calls to PUT Bucket policy if the specified bucket policy allows public <br>access. | `bool` | `true` | no |
| <a name="input_cache_allowed_methods"></a> [cache\_allowed\_methods](#input\_cache\_allowed\_methods) | Controls which HTTP methods CloudFront processes and forwards to your Amazon S3<br>bucket or your custom origin. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cache_compress"></a> [cache\_compress](#input\_cache\_compress) | Whether you want CloudFront to automatically compress content for web requests<br>that include Accept-Encoding: gzip in the request header. | `bool` | `true` | no |
| <a name="input_cache_default_ttl"></a> [cache\_default\_ttl](#input\_cache\_default\_ttl) | The default amount of time (in seconds) that an object is in a CloudFront cache<br>before CloudFront forwards another request in the absence of an Cache-Control<br>max-age or Expires header. | `number` | `3600` | no |
| <a name="input_cache_max_ttl"></a> [cache\_max\_ttl](#input\_cache\_max\_ttl) | The maximum amount of time (in seconds) that an object is in a CloudFront cache<br>before CloudFront forwards another request to your origin to determine whether<br>the object has been updated. Only effective in the presence of Cache-Control<br>max-age, Cache-Control s-maxage, and Expires headers. | `number` | `3600` | no |
| <a name="input_cache_min_ttl"></a> [cache\_min\_ttl](#input\_cache\_min\_ttl) | The minimum amount of time that you want objects to stay in CloudFront caches<br>before CloudFront queries your origin to see whether the object has been<br>updated. | `number` | `3600` | no |
| <a name="input_cache_target_origin_id"></a> [cache\_target\_origin\_id](#input\_cache\_target\_origin\_id) | The value of ID for the origin that you want CloudFront to route requests to<br>when a request matches the path pattern either for a cache behavior or for the<br>default cache behavior. | `string` | `"S3Origin"` | no |
| <a name="input_cache_viewer_proto_policy"></a> [cache\_viewer\_proto\_policy](#input\_cache\_viewer\_proto\_policy) | Use this element to specify the protocol that users can use to access the files<br>in the origin specified by TargetOriginId when a request matches the path<br>pattern in PathPattern. Options: allow-all, https-only, or redirect-to-https. | `string` | `"redirect-to-https"` | no |
| <a name="input_cached_methods"></a> [cached\_methods](#input\_cached\_methods) | Controls whether CloudFront caches the response to requests using the specified<br>HTTP methods. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cert_validation_method"></a> [cert\_validation\_method](#input\_cert\_validation\_method) | The validation method for the ACM cert. Options: DNS or Email. | `string` | `"DNS"` | no |
| <a name="input_cloudfront_default_certificate"></a> [cloudfront\_default\_certificate](#input\_cloudfront\_default\_certificate) | Set this to true if you want viewers to use HTTPS to request your objects and<br>you're using the CloudFront domain name for your distribution. This should be<br>specified in addition to  acm\_certificate\_arn, or iam\_certificate\_id. | `bool` | `false` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Any comments you want to include about the distribution. | `string` | `null` | no |
| <a name="input_create_cert_validation"></a> [create\_cert\_validation](#input\_create\_cert\_validation) | Whether to create a certificate validation request. This is useful for<br>applications that do not follow the <app\_name>.disney.com convention. Should be<br>set to true when creating a new CloudFront distribution but once available, set<br>this to false. | `bool` | `true` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create a bucket. This is useful when creating/testing multiple<br>resources in addition to the bucket." | `bool` | `true` | no |
| <a name="input_default_name"></a> [default\_name](#input\_default\_name) | The default name for the CloudFront distribution. | `string` | `""` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | The object that you want CloudFront to return (for example, index.html) when an<br>end user requests the root URL. | `string` | `"index.html"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The AWS ACM certificate name. | `string` | `""` | no |
| <a name="input_enable_acceleration"></a> [enable\_acceleration](#input\_enable\_acceleration) | Whether to enable acceleration. | `bool` | `false` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Whether to enable Server Side Encryption. | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Whether to enable Versioning. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the distribution is enabled to accept end user requests for content. | `bool` | `true` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Used to create a custom DNS record for the distribution. | `string` | `""` | no |
| <a name="input_err_cache_min_ttl"></a> [err\_cache\_min\_ttl](#input\_err\_cache\_min\_ttl) | The minimum amount of time (in seconds) you want HTTP error codes to stay in <br>CloudFront caches before CloudFront queries your origin to see whether the <br>object has been updated. | `number` | `10` | no |
| <a name="input_err_code_one"></a> [err\_code\_one](#input\_err\_code\_one) | The 4xx or 5xx HTTP status code that should be returned. | `number` | `404` | no |
| <a name="input_err_code_two"></a> [err\_code\_two](#input\_err\_code\_two) | The 4xx or 5xx HTTP status code that should be returned. | `number` | `403` | no |
| <a name="input_err_resp_code_one"></a> [err\_resp\_code\_one](#input\_err\_resp\_code\_one) | The HTTP status code that you want CloudFront to return with the custom error<br>page to the viewer. | `number` | `200` | no |
| <a name="input_err_resp_code_two"></a> [err\_resp\_code\_two](#input\_err\_resp\_code\_two) | The HTTP status code that you want CloudFront to return with the custom error<br>page to the viewer. | `number` | `200` | no |
| <a name="input_err_resp_page_path"></a> [err\_resp\_page\_path](#input\_err\_resp\_page\_path) | The path of the custom error page. | `string` | `"/index.html"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects (including any locked objects) should be<br>deleted from the bucket so that the bucket can be destroyed without error.<br>These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_fwd_value_cookie_fwd"></a> [fwd\_value\_cookie\_fwd](#input\_fwd\_value\_cookie\_fwd) | Specifies whether you want CloudFront to forward cookies to the origin that is<br>associated with this cache behavior. You can specify all, none or whitelist. If<br>whitelist, you must include the subsequent whitelisted\_names. | `string` | `"none"` | no |
| <a name="input_fwd_value_query_string"></a> [fwd\_value\_query\_string](#input\_fwd\_value\_query\_string) | Indicates whether you want CloudFront to forward query strings to the origin<br>that is associated with this cache behavior. | `bool` | `true` | no |
| <a name="input_generate_new"></a> [generate\_new](#input\_generate\_new) | A random string to use for the External ID. | `string` | `"something random but known"` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are<br>http1.1, http2, http2and3 and http3. | `string` | `"http2"` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. Enabling this <br>setting does not affect the persistence of any existing ACLs and doesn't prevent <br>new public ACLs from being set. When set to true causes Amazon S3 to:<br>Ignore public ACLs on this bucket and any objects that it contains. | `bool` | `true` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Whether the IPv6 is enabled for the distribution. | `bool` | `true` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used<br>when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS<br>master key is used if this element is absent while the sse\_algorithm is aws:kms. | `bool` | `false` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | The logging configuration that controls how logs are written to your <br>distribution (maximum one). | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The application/website name. E.g., foo in foo.bar.com. | `string` | `""` | no |
| <a name="input_origin_id"></a> [origin\_id](#input\_origin\_id) | A unique identifier for the origin. | `string` | `"S3Origin"` | no |
| <a name="input_origin_path"></a> [origin\_path](#input\_origin\_path) | A unique identifier for the origin path. This assumes that the directory <br>structure is the following s3\_bucket\_name/current is the cloudfront origin path <br>and /backups is the location of the tar.gz backup file for the deployment. | `string` | `""` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid list of bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `list(string)` | `[]` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | The price class for this distribution. Options: PriceClass\_All, PriceClass\_200,<br>PriceClass\_100. | `string` | `"PriceClass_All"` | no |
| <a name="input_r53_record_ttl"></a> [r53\_record\_ttl](#input\_r53\_record\_ttl) | The TTL (time-to-live) of the record in seconds. This is required for non-alias<br>records. | `number` | `60` | no |
| <a name="input_r53_record_type"></a> [r53\_record\_type](#input\_r53\_record\_type) | The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, <br>SOA, SPF, SRV and TXT. | `string` | `"CNAME"` | no |
| <a name="input_r53_zone_private"></a> [r53\_zone\_private](#input\_r53\_zone\_private) | Whether the Route53 zone is private. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which services are provisioned. | `string` | `"us-east-1"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. <br>Enabling this setting does not affect the previously stored bucket policy, <br>except that public and cross-account access within the public bucket policy, <br>including non-public delegation to specific accounts, is blocked. When set to <br>true:<br>Only the bucket owner and AWS Services can access this buckets if it has a <br>public policy. | `bool` | `true` | no |
| <a name="input_restriction_type"></a> [restriction\_type](#input\_restriction\_type) | The method that you want to use to restrict distribution of your content by<br>country. Options: none, whitelist, or blacklist. | `string` | `"none"` | no |
| <a name="input_s3_custom_policy"></a> [s3\_custom\_policy](#input\_s3\_custom\_policy) | An optional custom IAM policy to attach to the S3 bucket. | `string` | `""` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Options are AES256 and aws:kms. | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The default tags to add to a resource. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether to enable versioning of objects in the bucket. | `bool` | `true` | no |
| <a name="input_viewer_cert_min_proto_version"></a> [viewer\_cert\_min\_proto\_version](#input\_viewer\_cert\_min\_proto\_version) | The minimum version of the SSL protocol that you want CloudFront to use for <br>HTTPS connections. Can only be set if cloudfront\_default\_certificate = false. <br>See all possible values in this table under "Security policy." Some examples <br>include: TLSv1.2\_2019 and TLSv1.2\_2021. Default: TLSv1. NOTE: If you are using a <br>custom certificate (specified with acm\_certificate\_arn or iam\_certificate\_id), <br>and have specified sni-only in ssl\_support\_method, TLSv1 or later must be <br>specified. If you have specified vip in ssl\_support\_method, only SSLv3 or <br>TLSv1 can be specified. If you have specified cloudfront\_default\_certificate, <br>TLSv1 must be specified. | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_viewer_cert_ssl_support_method"></a> [viewer\_cert\_ssl\_support\_method](#input\_viewer\_cert\_ssl\_support\_method) | Specifies how you want CloudFront to serve HTTPS requests. One of vip or<br>sni-only. Required if you specify acm\_certificate\_arn or iam\_certificate\_id.<br>NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra<br>charges. | `string` | `"sni-only"` | no |
| <a name="input_waf_acl_default_action_type"></a> [waf\_acl\_default\_action\_type](#input\_waf\_acl\_default\_action\_type) | Configuration block with action that you want AWS WAF to take when a request<br>doesn't match the criteria in any of the rules that are associated with the web<br>ACL. | `string` | `"ALLOW"` | no |
| <a name="input_waf_acl_metric_name"></a> [waf\_acl\_metric\_name](#input\_waf\_acl\_metric\_name) | The name or description for the Amazon CloudWatch metric of this web ACL." | `string` | `"AllowAccessFromEverywhere"` | no |
| <a name="input_waf_acl_name"></a> [waf\_acl\_name](#input\_waf\_acl\_name) | The name or description of the web ACL. | `string` | `"Allow access from everywhere"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cdn_domain"></a> [cdn\_domain](#output\_cdn\_domain) | The CloudFront domain autogenerated by AWS. |
| <a name="output_cdn_id"></a> [cdn\_id](#output\_cdn\_id) | The CloudFront distribution ID. |
| <a name="output_cicd_role_arn"></a> [cicd\_role\_arn](#output\_cicd\_role\_arn) | The ARN of the generated role. |
| <a name="output_external_id"></a> [external\_id](#output\_external\_id) | The external ID to be passed using the `--external-id` flag of the<br>`aws sts assume-role` command. |
| <a name="output_s3_origin_bucket"></a> [s3\_origin\_bucket](#output\_s3\_origin\_bucket) | The origin bucket Cloudfront will use to get the content. |
