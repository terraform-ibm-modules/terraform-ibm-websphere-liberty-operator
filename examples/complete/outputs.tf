########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "cluster_id" {
  description = "Cluster ID"
  value       = module.ocp_base.cluster_id
}

output "websphere_liberty_sampleapp_url" {
  description = "Url of the IBM WebSphere Liberty sample application"
  value       = module.websphere_liberty_operator.websphere_liberty_operator_sampleapp_url
}
