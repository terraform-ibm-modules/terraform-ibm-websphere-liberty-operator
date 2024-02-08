##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source                 = "terraform-ibm-modules/landing-zone/ibm//patterns//roks//module"
  version                = "v5.1.1-rc"
  region                 = var.region
  prefix                 = var.prefix
  tags                   = var.resource_tags
  enable_transit_gateway = false
  add_atracker_route     = false
}
