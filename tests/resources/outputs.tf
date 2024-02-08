##############################################################################
# Outputs
##############################################################################

output "prefix" {
  value       = module.landing_zone.prefix
  description = "prefix"
}

output "region" {
  value       = var.region
  description = "Region where SLZ ROKS Cluster is deployed."
}

output "management_cluster_id" {
  value = lookup(
    [for cluster in module.landing_zone.cluster_data : cluster if strcontains(cluster.resource_group_name, "management")][0], "id", ""
  )
  description = "management cluster ID"
}

output "workload_cluster_id" {
  value = lookup(
    [for cluster in module.landing_zone.cluster_data : cluster if strcontains(cluster.resource_group_name, "workload")][0], "id", ""
  )
  description = "workload cluster ID"
}
