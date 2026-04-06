module "simple-cdn-with-s3" {
  source = "../../"
  # myapp is merely a placeholder. Replace it with actual name.
  name      = "myapp"
  zone_name = "nurdsoft.co"
  tags = {
    application_name = "myapp"
    owner            = "hello@nurdsoft.co"
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