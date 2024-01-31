##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to use, set via environment variable TF_VAR_ibmcloud_api_key"
  type        = string
  sensitive   = true
  default     = null
}

variable "cluster_id" {
  type        = string
  description = "Id of the target IBM Cloud OpenShift Cluster"
}

variable "ws_liberty_operator_namespace" {
  type        = string
  description = "Namespace to install the WebSphere Liberty Operator. Default to openshift-operators"
  default     = "openshift-operators"
}

variable "ws_liberty_operator_target_namespace" {
  type        = string
  description = "Namespace to be watched by the WebSphere Liberty Operator. Default to null (operator to watch all namespaces)"
  default     = null
}
