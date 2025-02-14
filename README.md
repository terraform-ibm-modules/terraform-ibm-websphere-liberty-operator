<!-- Update the title -->
# WebSphere Liberty on Red Hat OpenShift Container Platform module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-websphere-liberty-operator?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-websphere-liberty-operator/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
Use this module to install a WebSphere Liberty operator on your Red Hat OpenShift Container Platform on VPC landing zone.

For more information about the IBM WebSphere Liberty operator refer to the official documentation avaiable [here](https://www.ibm.com/docs/en/was-liberty/core?topic=container-running-websphere-liberty-operator)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-websphere-liberty-operator](#terraform-ibm-websphere-liberty-operator)
* [Examples](./examples)
    * [Complete example for Websphere Liberty operator](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-websphere-liberty-operator

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

##############################################################################
# Config providers
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key # pragma: allowlist secret
  region           = var.region
}

provider "helm" {
  kubernetes {
    host  = data.ibm_container_cluster_config.cluster_config.host
    token = data.ibm_container_cluster_config.cluster_config.token
  }
}

provider "kubernetes" {
  host  = data.ibm_container_cluster_config.cluster_config.host
  token = data.ibm_container_cluster_config.cluster_config.token
}

##############################################################################
# IBM WebSphere Liberty operator deployment on the OCP cluster
##############################################################################

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.cluster_id
  config_dir      = "${path.module}/kubeconfig"
  endpoint_type   = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null # null represents default
}

module "websphere_liberty_operator" {
  # Replace "master" with a GIT release version to lock into a specific release
  source                                    = "https://github.com/terraform-ibm-modules/terraform-ibm-websphere-liberty-operator.git?ref=master"
  cluster_id                                = var.cluster_id
  add_ibm_operator_catalog                  = true
  create_ws_liberty_operator_namespace      = false
  ws_liberty_operator_namespace             = "ws-liberty-operator-namespace"
  ws_liberty_operator_target_namespace      = "openshift-operators"
  cluster_config_endpoint_type              = "default"
  install_wslo_sampleapp                    = true
  wslo_sampleapp_name                       = "sample-app"
  wslo_sampleapp_namespace                  = "sample-app-namespace"
  operator_helm_release_namespace           = "liberty-operator-helm-release"
  ws_liberty_operator_install_plan_approval = "Automatic"
}

locals {
  websphere_liberty_operator_sampleapp_url = var.install_wslo_sampleapp == true ? "https://${module.websphere_liberty_operator.websphere_liberty_operator_sampleapp_url}" : null
}

output "websphere_liberty_operator_sample_app_url" {
  description = "URL of the IBM WebSphere Liberty operator sample app if deployed."
  value       = local.websphere_liberty_operator_sampleapp_url
}
```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

- IAM Services
  - **Kubernetes** service
      - `Viewer` platform access
      - `Manager` service access

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >=2.2.3, <3.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8.0, <3.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.59.0, < 2.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1, <3.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.ibm_operator_catalog](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.websphere_liberty_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.websphere_liberty_operator_group](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.websphere_liberty_operator_sampleapp](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.helm_release_operator_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.websphere_liberty_operator_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.websphere_liberty_sampleapp_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [null_resource.confirm_websphere_liberty_operator_operational](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_catalog](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_sampleapp](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_websphere_liberty_operator](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [external_external.websphere_liberty_operator_sampleapp_url](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_container_cluster_config.cluster_config](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/container_cluster_config) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_ibm_operator_catalog"></a> [add\_ibm\_operator\_catalog](#input\_add\_ibm\_operator\_catalog) | Whether to configure the IBM Operator Catalog in the cluster before the IBM WebSphere Liberty operator is installed. Default is `true`. | `bool` | `true` | no |
| <a name="input_cluster_config_endpoint_type"></a> [cluster\_config\_endpoint\_type](#input\_cluster\_config\_endpoint\_type) | Specify which type of endpoint to use for for cluster config access: 'default', 'private', 'vpe', 'link'. 'default' value will use the default endpoint of the cluster. | `string` | `"default"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Id of the target IBM Cloud OpenShift Cluster. | `string` | n/a | yes |
| <a name="input_create_ws_liberty_operator_namespace"></a> [create\_ws\_liberty\_operator\_namespace](#input\_create\_ws\_liberty\_operator\_namespace) | Whether to create the namespace where the IBM WebSphere Liberty operator is deployed. Default is `false`. | `bool` | `false` | no |
| <a name="input_install_wslo_sampleapp"></a> [install\_wslo\_sampleapp](#input\_install\_wslo\_sampleapp) | Whether to deploy the WebSphere Application Server Liberty sample application. Default is  `false`. | `bool` | `false` | no |
| <a name="input_operator_helm_release_namespace"></a> [operator\_helm\_release\_namespace](#input\_operator\_helm\_release\_namespace) | Namespace to deploy the helm releases. Default to liberty-operator-helm-release. | `string` | `"liberty-operator"` | no |
| <a name="input_ws_liberty_operator_install_plan_approval"></a> [ws\_liberty\_operator\_install\_plan\_approval](#input\_ws\_liberty\_operator\_install\_plan\_approval) | IBM WebSphere Liberty operator approval configuration for OLM upgrade. Set to 'Manual' to manually approve the operator upgrades. Default is `Automatic`. | `string` | `"Automatic"` | no |
| <a name="input_ws_liberty_operator_namespace"></a> [ws\_liberty\_operator\_namespace](#input\_ws\_liberty\_operator\_namespace) | Namespace where the IBM WebSphere Liberty operator is deployed. Default is `openshift-operators`. | `string` | `"openshift-operators"` | no |
| <a name="input_ws_liberty_operator_target_namespace"></a> [ws\_liberty\_operator\_target\_namespace](#input\_ws\_liberty\_operator\_target\_namespace) | Namespace that the the IBM WebSphere Liberty operator watches. Default is `null`, which means that the operator watches all the namespaces. | `string` | `null` | no |
| <a name="input_wslo_sampleapp_name"></a> [wslo\_sampleapp\_name](#input\_wslo\_sampleapp\_name) | Application name to use for the WebSphere Application Server Liberty sample application. | `string` | `"websphereliberty-app-sample"` | no |
| <a name="input_wslo_sampleapp_namespace"></a> [wslo\_sampleapp\_namespace](#input\_wslo\_sampleapp\_namespace) | Namespace where the WebSphere Application Server Liberty sample application is deployed. | `string` | `"samplelibertyapp"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_websphere_liberty_operator_sampleapp_url"></a> [websphere\_liberty\_operator\_sampleapp\_url](#output\_websphere\_liberty\_operator\_sampleapp\_url) | WebSphere Application Server Liberty sample application URL. |
| <a name="output_ws_liberty_operator_namespace"></a> [ws\_liberty\_operator\_namespace](#output\_ws\_liberty\_operator\_namespace) | Namespace where the IBM WebSphere Liberty operator is installed. |
| <a name="output_ws_liberty_operator_target_namespace"></a> [ws\_liberty\_operator\_target\_namespace](#output\_ws\_liberty\_operator\_target\_namespace) | Namespace watched by the IBM WebSphere Liberty operator. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
