variable "ibmcloud_api_key" {
  type        = string
  description = "APIkey associated with the account to use"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this solution"
  default     = "au-syd"
}

variable "cluster_id" {
  type        = string
  description = "Id of the target IBM Cloud OpenShift Cluster"
  nullable    = false
}

variable "operator_helm_release_namespace" {
  type        = string
  description = "Namespace to deploy the helm releases. Default to liberty-operator-helm-release"
  default     = "liberty-operator-helm-release"
}

variable "add_ibm_operator_catalog" {
  type        = bool
  description = "Flag to configure the IBM Operator Catalog in the cluster before installing the WebSphere Liberty Operator. Default is true"
  default     = true
}

variable "create_ws_liberty_operator_namespace" {
  type        = bool
  description = "Flag to create the namespace where to deploy the WebSphere Liberty Operator. Default to false"
  default     = false
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
  description = "Flag to deploy the WebSphere Liberty sample application. Default to false"
  type        = bool
  default     = false
}

variable "wslo_sampleapp_name" {
  description = "Application name to use for the WebSphere Liberty sample application"
  type        = string
  default     = "websphereliberty-app-sample"
}

variable "wslo_sampleapp_namespace" {
  description = "Namespace to deploy the WebSphere Liberty sample application"
  type        = string
  default     = "samplelibertyapp"
}
