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
  source           = "../../"
  name             = local.bucket_name
  s3_custom_policy = data.aws_iam_policy_document.bucket_policy.json
  tags = {
    application_name = "myapp"
    owner            = "hello@nurdsoft.co"
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
  }
}