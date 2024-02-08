##############################################################################
# Outputs
##############################################################################

output "prefix" {
  value       = module.landing_zone.prefix
  description = "prefix"
}

output "cluster_id" {
  value = lookup(
    [for cluster in module.landing_zone.cluster_data : cluster][0], "cluster_id", ""
  )
  description = "cluster ID"
}
