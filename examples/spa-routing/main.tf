# Example: CloudFront distribution with SPA routing enabled
#
# Use this configuration for static sites built with frameworks like Gatsby,
# Next.js (static export), or Create React App. Without SPA routing, CloudFront
# serves the root index.html for every path (because S3 in REST-API mode does
# not resolve directory index documents). This causes Gatsby's window.pagePath
# to always be "/" and every sub-route to render the homepage.
#
# Setting enable_spa_routing = true attaches a lightweight CloudFront Function
# that rewrites directory-style requests at the edge:
#
#   /about/    -> /about/index.html
#   /blog/     -> /blog/index.html
#   /blog/my-post/ -> /blog/my-post/index.html
#
# Requests that already carry a file extension (JS, CSS, images, etc.) are
# passed through unchanged.

module "spa-cdn" {
  source = "../../"
  # Replace with the actual domain name for your application.
  name = "myapp.nurdsoft.co"

  # Enable the SPA directory-index routing function.
  enable_spa_routing = true

  tags = {
    application_name = "myapp"
    owner            = "hello@nurdsoft.co"
    cloud            = "aws"
    environment      = "dev"
    region           = "use1"
  }
}
