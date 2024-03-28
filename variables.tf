##############################################################################
# Input Variables
##############################################################################

variable "cluster_id" {
  type        = string
  description = "Id of the target IBM Cloud OpenShift Cluster."
  nullable    = false
}

variable "operator_helm_release_namespace" {
  type        = string
  description = "Namespace to deploy the helm releases. Default to liberty-operator-helm-release."
  default     = "liberty-operator"
  nullable    = false
}

variable "add_ibm_operator_catalog" {
  type        = bool
  description = "Whether to configure the IBM Operator Catalog in the cluster before the IBM WebSphere Liberty operator is installed. Default is `true`."
  default     = true
}

variable "create_ws_liberty_operator_namespace" {
  type        = bool
  description = "Whether to create the namespace where the IBM WebSphere Liberty operator is deployed. Default is `false`."
  default     = false
}

variable "ws_liberty_operator_namespace" {
  type        = string
  description = "Namespace where the IBM WebSphere Liberty operator is deployed. Default is `openshift-operators`."
  default     = "openshift-operators"
  nullable    = false
}

variable "ws_liberty_operator_target_namespace" {
  type        = string
  description = "Namespace that the the IBM WebSphere Liberty operator watches. Default is `null`, which means that the operator watches all the namespaces."
  default     = null
}

variable "ws_liberty_operator_install_plan_approval" {
  type        = string
  description = "IBM WebSphere Liberty operator approval configuration for OLM upgrade. Set to 'Manual' to manually approve the operator upgrades. Default is `Automatic`."
  default     = "Automatic"
  validation {
    error_message = "Invalid install plan approval configuration! Valid values are 'Automatic' or 'Manual'"
    condition     = contains(["Automatic", "Manual"], var.ws_liberty_operator_install_plan_approval)
  }
  nullable = false
}


variable "cluster_config_endpoint_type" {
  description = "Specify which type of endpoint to use for for cluster config access: 'default', 'private', 'vpe', 'link'. 'default' value will use the default endpoint of the cluster."
  type        = string
  default     = "default"
  nullable    = false # use default if null is passed in
  validation {
    error_message = "Invalid Endpoint Type! Valid values are 'default', 'private', 'vpe', or 'link'"
    condition     = contains(["default", "private", "vpe", "link"], var.cluster_config_endpoint_type)
  }
}

variable "install_wslo_sampleapp" {
  description = "Whether to deploy the WebSphere Application Server Liberty sample application. Default is  `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "wslo_sampleapp_name" {
  description = "Application name to use for the WebSphere Application Server Liberty sample application."
  type        = string
  default     = "websphereliberty-app-sample"
}

variable "wslo_sampleapp_namespace" {
  description = "Namespace where the WebSphere Application Server Liberty sample application is deployed."
  type        = string
  default     = "samplelibertyapp"
}
