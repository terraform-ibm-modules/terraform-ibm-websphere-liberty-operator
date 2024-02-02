########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "cluster_subnets" {
  description = "Subnets created in the VPC for the cluster"
  value       = ibm_is_subnet.cluster_subnets
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "cluster_id" {
  description = "Resource group name"
  value       = module.ocp_base.cluster_id
}

output "websphere_liberty_sampleapp_url" {
  description = "Url of the IBM WebSphere Liberty sample application"
  value       = module.websphere_liberty_operator.websphere_liberty_operator_sampleapp_url
}
