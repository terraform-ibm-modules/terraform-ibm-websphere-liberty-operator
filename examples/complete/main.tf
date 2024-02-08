########################################################################################################################
# Resource Group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# VPC
########################################################################################################################

resource "ibm_is_vpc" "vpc" {
  name                      = "${var.prefix}-vpc"
  resource_group            = module.resource_group.resource_group_id
  address_prefix_management = "auto"
  tags                      = var.resource_tags
}

# public gws
resource "ibm_is_public_gateway" "gateway" {
  for_each       = toset(["1", "2", "3"])
  name           = "${var.prefix}-gateway-${each.key}"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region}-${each.key}"
}


resource "ibm_is_subnet" "cluster_subnets" {
  for_each                 = toset(["1", "2", "3"])
  name                     = "${var.prefix}-subnet-${each.key}"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = module.resource_group.resource_group_id
  zone                     = "${var.region}-${each.key}"
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway[each.key].id
}

##############################################################################
# OCP CLUSTER
##############################################################################

locals {

  subnets = [
    for subnet in ibm_is_subnet.cluster_subnets :
    {
      id         = subnet.id
      zone       = subnet.zone
      cidr_block = subnet.ipv4_cidr_block
    }
  ]

  # mapping of cluster worker pool names to subnets
  cluster_vpc_subnets = {
    zone-1 = local.subnets,
    zone-2 = local.subnets,
    zone-3 = local.subnets
  }

  worker_pools = [
    {
      subnet_prefix    = "zone-1"
      pool_name        = "default" # ibm_container_vpc_cluster automatically names default pool "default" (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2849)
      machine_type     = "bx2.4x16"
      workers_per_zone = 1
      labels           = {}
    },
    {
      subnet_prefix    = "zone-2"
      pool_name        = "zone-2"
      machine_type     = "bx2.4x16"
      workers_per_zone = 1
      labels           = { "dedicated" : "edge" }
    },
    {
      subnet_prefix    = "zone-3"
      pool_name        = "zone-3"
      machine_type     = "bx2.4x16"
      workers_per_zone = 1
      labels           = { "dedicated" : "transit" }
    }
  ]
}

module "ocp_base" {
  depends_on           = [ibm_is_vpc.vpc, ibm_is_subnet.cluster_subnets, ibm_is_public_gateway.gateway]
  source               = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version              = "3.10.1"
  cluster_name         = "${var.prefix}-cluster"
  cos_name             = "${var.prefix}-cos"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  force_delete_storage = true
  vpc_id               = ibm_is_vpc.vpc.id
  vpc_subnets          = local.cluster_vpc_subnets
  worker_pools         = local.worker_pools
  tags                 = var.resource_tags
  ibmcloud_api_key     = var.ibmcloud_api_key
  ocp_version          = var.ocp_version
}


##############################################################################
# IBM WebSphere Liberty operator deployment on the OCP cluster
##############################################################################

module "websphere_liberty_operator" {
  source                               = "../.."
  region                               = var.region
  cluster_id                           = module.ocp_base.cluster_id
  create_ws_liberty_operator_namespace = false
  install_wslo_sampleapp               = true
  ibmcloud_api_key                     = var.ibmcloud_api_key
}
