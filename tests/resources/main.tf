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
    "atracker": {},
    "clusters": [
        {
            "cos_name": "cos",
            "entitlement": "cloud_pak",
            "kube_type": "openshift",
            "kube_version": "default",
            "machine_type": "bx2.16x64",
            "name": "management-cluster",
            "resource_group": "slz-management-rg",
            "kms_config": {
                "crk_name": "slz-roks-key",
                "private_endpoint": true
            },
            "subnet_names": [
                "vsi-zone-1",
                "vsi-zone-2",
                "vsi-zone-3"
            ],
            "vpc_name": "management",
            "worker_pools": [
                {
                    "entitlement": "cloud_pak",
                    "flavor": "bx2.16x64",
                    "name": "logging-worker-pool",
                    "subnet_names": [
                        "vsi-zone-1",
                        "vsi-zone-2",
                        "vsi-zone-3"
                    ],
                    "vpc_name": "management",
                    "workers_per_subnet": 2
                }
            ],
            "workers_per_subnet": 2
        },
        {
            "cos_name": "cos",
            "entitlement": "cloud_pak",
            "kube_type": "openshift",
            "kube_version": "default",
            "machine_type": "bx2.16x64",
            "name": "workload-cluster",
            "resource_group": "slz-workload-rg",
            "kms_config": {
                "crk_name": "slz-roks-key",
                "private_endpoint": true
            },
            "subnet_names": [
                "vsi-zone-1",
                "vsi-zone-2",
                "vsi-zone-3"
            ],
            "vpc_name": "workload",
            "worker_pools": [
                {
                    "entitlement": "cloud_pak",
                    "flavor": "bx2.16x64",
                    "name": "logging-worker-pool",
                    "subnet_names": [
                        "vsi-zone-1",
                        "vsi-zone-2",
                        "vsi-zone-3"
                    ],
                    "vpc_name": "workload",
                    "workers_per_subnet": 2
                }
            ],
            "workers_per_subnet": 2
        }
    ],
    "cos": [
        {
            "buckets": [
                {
                    "endpoint_type": "public",
                    "force_delete": true,
                    "kms_key": "slz-atracker-key",
                    "name": "atracker-bucket",
                    "storage_class": "standard",
                    "region_location": "us-south",
                    "hard_quota": 0,
                    "allowed_ip": [],
                    "expire_rule": {
                        "rule_id": "a-bucket-expire-rule",
                        "enable": true,
                        "days": 30,
                        "prefix": "logs/"
                    },
                    "archive_rule": {
                        "rule_id": "a-bucket-arch-rule",
                        "enable": false,
                        "days": 0,
                        "type": "GLACIER"
                    },
                    "activity_tracking": {
                        "read_data_events": true,
                        "write_data_events": true,
                        "activity_tracker_crn": "activity-tracker-crn"
                    },
                        "metrics_monitoring": {
                        "usage_metrics_enabled": true,
                        "request_metrics_enabled": true,
                        "metrics_monitoring_crn": "metrics-monitor-crn"
                    }
                }
            ],
            "keys": [
                {
                    "name": "cos-bind-key",
                    "role": "Writer",
                    "enable_HMAC": false
                }
            ],
            "name": "atracker-cos",
            "plan": "standard",
            "resource_group": "slz-service-rg",
            "use_data": false
        },
        {
            "buckets": [
                {
                    "endpoint_type": "public",
                    "force_delete": true,
                    "kms_key": "slz-slz-key",
                    "name": "management-bucket",
                    "storage_class": "standard",
                    "region_location": "us-south",
                    "hard_quota": 0,
                    "allowed_ip": [],
                    "expire_rule": {
                        "rule_id": "a-bucket-expire-rule",
                        "enable": true,
                        "days": 30,
                        "prefix": "logs/"
                    },
                    "archive_rule": {
                        "rule_id": "a-bucket-arch-rule",
                        "enable": false,
                        "days": 0,
                        "type": "GLACIER"
                    },
                    "activity_tracking": {
                        "read_data_events": true,
                        "write_data_events": true,
                        "activity_tracker_crn": "activity-tracker-crn"
                    },
                        "metrics_monitoring": {
                        "usage_metrics_enabled": true,
                        "request_metrics_enabled": true,
                        "metrics_monitoring_crn": "metrics-monitor-crn"
                    }
                },
                {
                    "endpoint_type": "public",
                    "force_delete": true,
                    "kms_key": "slz-slz-key",
                    "name": "workload-bucket",
                    "storage_class": "standard",
                    "region_location": "us-south",
                    "hard_quota": 0,
                    "allowed_ip": [],
                    "expire_rule": {
                        "rule_id": "a-bucket-expire-rule",
                        "enable": true,
                        "days": 30,
                        "prefix": "logs/"
                    },
                    "archive_rule": {
                        "rule_id": "a-bucket-arch-rule",
                        "enable": false,
                        "days": 0,
                        "type": "GLACIER"
                    },
                    "activity_tracking": {
                        "read_data_events": true,
                        "write_data_events": true,
                        "activity_tracker_crn": "activity-tracker-crn"
                    },
                        "metrics_monitoring": {
                        "usage_metrics_enabled": true,
                        "request_metrics_enabled": true,
                        "metrics_monitoring_crn": "metrics-monitor-crn"
                    }
                }
            ],
            "keys": [],
            "name": "cos",
            "plan": "standard",
            "resource_group": "slz-service-rg",
            "use_data": false
        }
    ],
    "enable_transit_gateway": true,
    "transit_gateway_global": false,
    "key_management": {
        "keys": [
            {
                "key_ring": "slz-slz-ring",
                "name": "slz-slz-key",
                "root_key": true
            },
            {
                "key_ring": "slz-slz-ring",
                "name": "slz-atracker-key",
                "root_key": true
            },
            {
                "key_ring": "slz-slz-ring",
                "name": "slz-vsi-volume-key",
                "root_key": true
            },
            {
                "key_ring": "slz-slz-ring",
                "name": "slz-roks-key",
                "root_key": true
            }
        ],
        "name": "slz-slz-kms",
        "resource_group": "slz-service-rg",
        "use_hs_crypto": false
    },
    "resource_groups": [
        {
            "create": true,
            "name": "slz-service-rg"
        },
        {
            "create": true,
            "name": "slz-management-rg"
        },
        {
            "create": true,
            "name": "slz-workload-rg"
        }
    ],
    "security_groups": [],
    "service_endpoints": "public-and-private",
    "ssh_keys": [],
    "transit_gateway_connections": [
        "management",
        "workload"
    ],
    "transit_gateway_resource_group": "slz-service-rg",
    "virtual_private_endpoints": [
        {
            "service_name": "cos",
            "service_type": "cloud-object-storage",
            "resource_group": "slz-service-rg",
            "vpcs": [
                {
                    "name": "management",
                    "subnets": [
                        "vpe-zone-1",
                        "vpe-zone-2",
                        "vpe-zone-3"
                    ]
                },
                {
                    "name": "workload",
                    "subnets": [
                        "vpe-zone-1",
                        "vpe-zone-2",
                        "vpe-zone-3"
                    ]
                }
            ]
        }
    ],
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
    "vpn_gateways": [
        {
            "name": "management-gateway",
            "resource_group": "slz-management-rg",
            "subnet_name": "vpn-zone-1",
            "vpc_name": "management"
        }
    ],
    "vsi": [],
    "wait_till": "IngressReady"
}
EOF
}
