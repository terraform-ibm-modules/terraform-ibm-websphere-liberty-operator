########################################################################################################################
# Outputs
########################################################################################################################

output "ws_liberty_operator_namespace" {
  description = "Namespace where the WebSphere Liberty operator is installed"
  value       = var.ws_liberty_operator_namespace
}

output "ws_liberty_operator_target_namespace" {
  description = "Namespace watched by the WebSphere Liberty operator"
  value       = var.ws_liberty_operator_target_namespace
}

output "websphere_liberty_operator_sampleapp_url" {
  value       = data.external.websphere_liberty_operator_sampleapp_url[0].result.sampleapp_url
  description = "WebSphere Liberty sample application URL"
}
