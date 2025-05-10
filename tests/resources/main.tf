##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone//patterns//roks-quickstart?ref=v7.4.7"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  prefix           = var.prefix
  resource_tags    = var.resource_tags
}
