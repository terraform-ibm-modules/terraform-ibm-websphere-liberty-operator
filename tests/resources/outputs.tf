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
  value       = module.landing_zone.management_cluster_id
  description = "management cluster ID."
}

output "workload_cluster_id" {
  value       = module.landing_zone.workload_cluster_id
  description = "workload cluster ID."
}
