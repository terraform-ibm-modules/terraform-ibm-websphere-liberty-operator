##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source        = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone//patterns//roks-quickstart?ref=v5.21.0"
  region        = var.region
  prefix        = var.prefix
  resource_tags = var.resource_tags
}
