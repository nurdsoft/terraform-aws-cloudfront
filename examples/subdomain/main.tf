# Example: CloudFront distribution deployed to a subdomain
#
# Use this configuration when the site lives under a subdomain of an existing
# Route 53 hosted zone. For instance, if your hosted zone is "nurdsoft.co" and
# you want to serve "mswp.nurdsoft.co", set name = "mswp" and
# zone_name = "nurdsoft.co". The module constructs the FQDN automatically.

module "subdomain-cdn" {
  source = "../../"

  # The subdomain prefix (e.g. "mswp" → mswp.nurdsoft.co).
  name = "mswp"

  # The Route 53 hosted zone that already exists in your account.
  zone_name = "nurdsoft.co"

  tags = {
    application_name = "mswp"
    owner            = "hello@nurdsoft.co"
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
  }
}
