########################################################################################################################
# Outputs
########################################################################################################################

output "websphere_liberty_operator_deployment_namespace" {
  description = "Namespace where the IBM WebSphere Liberty operator is installed"
  value       = module.websphere_liberty_operator.ws_liberty_operator_namespace
}

output "websphere_liberty_operator_deployment_target_namespace" {
  description = "Namespace watched by the IBM WebSphere Liberty operator"
  value       = module.websphere_liberty_operator.ws_liberty_operator_target_namespace
}

output "websphere_liberty_operator_sample_app_url" {
  description = "Url of the IBM WebSphere Liberty operator sample app if deployed"
  value       = local.websphere_liberty_operator_sampleapp_url
}
