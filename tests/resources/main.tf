##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source                 = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone//patterns//roks//module?ref=v5.1.1-rc"
  region                 = var.region
  prefix                 = var.prefix
  tags                   = var.resource_tags
  enable_transit_gateway = false
  add_atracker_route     = false

  override_json_string = <<EOF
  {
    "vpcs": [
        {
            "default_security_group_rules": [],
            "clean_default_sg_acl": true,
            "flow_logs_bucket_name": "management-bucket",
            "network_acls": [
                {
                    "add_ibm_cloud_internal_rules": true,
                    "add_vpc_connectivity_rules": true,
                    "prepend_ibm_rules": true,
                    "name": "management-acl",
                    "rules": [
                        {
                            "action": "allow",
                            "destination": "10.0.0.0/8",
                            "direction": "inbound",
                            "name": "allow-ibm-inbound",
                            "source": "161.26.0.0/16"
                        },
                        {
                            "action": "allow",
                            "destination": "10.0.0.0/8",
                            "direction": "inbound",
                            "name": "allow-all-network-inbound",
                            "source": "10.0.0.0/8"
                        },
                        {
                            "action": "allow",
                            "destination": "161.26.0.0/16",
                            "direction": "outbound",
                            "name": "allow-all-outbound",
                            "source": "10.0.0.0/8"
                        }
                    ]
                }
            ],
            "prefix": "management",
            "resource_group": "slz-management-rg",
            "subnets": {
                "zone-1": [
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.10.10.0/24",
                        "name": "vsi-zone-1",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.10.20.0/24",
                        "name": "vpe-zone-1",
                        "public_gateway": false
                    },
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.10.30.0/24",
                        "name": "vpn-zone-1",
                        "public_gateway": false
                    }
                ],
                "zone-2": [
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.20.10.0/24",
                        "name": "vsi-zone-2",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.20.20.0/24",
                        "name": "vpe-zone-2",
                        "public_gateway": false
                    }
                ],
                "zone-3": [
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.30.10.0/24",
                        "name": "vsi-zone-3",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "management-acl",
                        "cidr": "10.30.20.0/24",
                        "name": "vpe-zone-3",
                        "public_gateway": false
                    }
                ]
            },
            "use_public_gateways": {
                "zone-1": true,
                "zone-2": true,
                "zone-3": true
            }
        },
        {
            "default_security_group_rules": [],
            "clean_default_sg_acl": true,
            "flow_logs_bucket_name": "workload-bucket",
            "network_acls": [
                {
                    "add_ibm_cloud_internal_rules": true,
                    "add_vpc_connectivity_rules": true,
                    "prepend_ibm_rules": true,
                    "name": "workload-acl",
                    "rules": [
                        {
                            "action": "allow",
                            "destination": "10.0.0.0/8",
                            "direction": "inbound",
                            "name": "allow-ibm-inbound",
                            "source": "161.26.0.0/16"
                        },
                        {
                            "action": "allow",
                            "destination": "10.0.0.0/8",
                            "direction": "inbound",
                            "name": "allow-all-network-inbound",
                            "source": "10.0.0.0/8"
                        },
                        {
                            "action": "allow",
                            "destination": "161.26.0.0/16",
                            "direction": "outbound",
                            "name": "allow-all-outbound",
                            "source": "10.0.0.0/8"
                        }
                    ]
                }
            ],
            "prefix": "workload",
            "resource_group": "slz-workload-rg",
            "subnets": {
                "zone-1": [
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.40.10.0/24",
                        "name": "vsi-zone-1",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.40.20.0/24",
                        "name": "vpe-zone-1",
                        "public_gateway": false
                    }
                ],
                "zone-2": [
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.50.10.0/24",
                        "name": "vsi-zone-2",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.50.20.0/24",
                        "name": "vpe-zone-2",
                        "public_gateway": false
                    }
                ],
                "zone-3": [
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.60.10.0/24",
                        "name": "vsi-zone-3",
                        "public_gateway": true
                    },
                    {
                        "acl_name": "workload-acl",
                        "cidr": "10.60.20.0/24",
                        "name": "vpe-zone-3",
                        "public_gateway": false
                    }
                ]
            },
            "use_public_gateways": {
                "zone-1": true,
                "zone-2": true,
                "zone-3": true
            }
        }
    ],
    "wait_till": "IngressReady"
}
EOF
}
