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
    application_name = "myapp"
    owner            = "Nurdsoft - devops@nurdsoft.co"
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
  }
  s3_cors_rules = [
    {
      allowed_methods = ["*"]
      allowed_origins = ["*"]
    }
  ]
}