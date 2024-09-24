##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone//patterns//roks-quickstart?ref=v6.0.0"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  prefix           = var.prefix
  resource_tags    = var.resource_tags
  # GHA runtime has no access to private endpoints, so set these to false
  verify_cluster_network_readiness    = false
  use_ibm_cloud_private_api_endpoints = false
}
