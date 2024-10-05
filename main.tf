locals {
  # sleep times definition
  sleep_time_catalog_create   = "60s"
  sleep_time_operator_create  = "120s"
  sleep_time_sampleapp_create = "30s" # time to wait for the sampleapp route to be defined

  # helm chart names
  ibm_operator_catalog_chart                 = "ibm-operator-catalog"
  websphere_liberty_operator_chart           = "websphere-liberty-operator"
  websphere_liberty_operator_group_chart     = "websphere-liberty-operator-group"
  websphere_liberty_operator_sampleapp_chart = "websphere-liberty-operator-sampleapp"

  # validation of ws_liberty_operator_target_namespace - if null the value of ws_liberty_operator_namespace must be equal to "openshift-operators" https://www.ibm.com/docs/en/was-liberty/core?topic=operator-installing-red-hat-openshift-cli#in-t-cli__install-op-cli__title__1
  default_liberty_operator_namespace = "openshift-operators"
  operator_target_namespace_cnd      = var.ws_liberty_operator_target_namespace == null && var.ws_liberty_operator_namespace != local.default_liberty_operator_namespace
  operator_target_namespace_msg      = "if input var ws_liberty_operator_target_namespace is null the value of ws_liberty_operator_namespace must be equal to ${local.default_liberty_operator_namespace}"
  # tflint-ignore: terraform_unused_declarations
  operator_target_namespace_chk = regex("^${local.operator_target_namespace_msg}$", (!local.operator_target_namespace_cnd ? local.operator_target_namespace_msg : ""))
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.cluster_id
  config_dir      = "${path.module}/kubeconfig"
  endpoint_type   = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null
}

# creating the namespace to deploy the helm releases to install the WebSphere Liberty Operator
resource "kubernetes_namespace" "helm_release_operator_namespace" {
  metadata {
    name = var.operator_helm_release_namespace
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

locals {
  ibm_operator_catalog_image_tag_digest = "v4.16@sha256:8a1128354bf95cf59ee268f7a7a3ceb50204e00585a2a9dab2f9d9b33e7ad23b" # datasource: icr.io/cpopen/ibm-operator-catalog
  ibm_operator_catalog_path             = "icr.io/cpopen/ibm-operator-catalog"
}

# if add_ibm_operator_catalog is true going on with adding the IBM Operator Catalog source
resource "helm_release" "ibm_operator_catalog" {
  depends_on = [kubernetes_namespace.helm_release_operator_namespace]
  count      = var.add_ibm_operator_catalog == true ? 1 : 0

  name             = "ibm-operator-catalog-helm-release"
  chart            = "${path.module}/chart/${local.ibm_operator_catalog_chart}"
  namespace        = var.operator_helm_release_namespace
  create_namespace = false
  timeout          = 300
  force_update     = true
  cleanup_on_fail  = false
  wait             = true
  recreate_pods    = true

  disable_openapi_validation = false

  set {
    name  = "image.path"
    type  = "string"
    value = local.ibm_operator_catalog_path
  }
  set {
    name  = "image.version"
    type  = "string"
    value = local.ibm_operator_catalog_image_tag_digest
  }
}

# waiting for the catalog to be configured and correctly pulled
resource "time_sleep" "wait_catalog" {
  depends_on = [helm_release.ibm_operator_catalog[0]]
  count      = var.add_ibm_operator_catalog == true ? 1 : 0

  create_duration = local.sleep_time_catalog_create
}

# if ws_liberty_operator_target_namespace != null the operator group must be created
resource "helm_release" "websphere_liberty_operator_group" {
  count      = var.ws_liberty_operator_target_namespace != null ? 1 : 0
  depends_on = [time_sleep.wait_catalog[0], kubernetes_namespace.helm_release_operator_namespace]

  name             = "websphere-liberty-operator-group-helm-release"
  chart            = "${path.module}/chart/${local.websphere_liberty_operator_group_chart}"
  namespace        = var.operator_helm_release_namespace
  create_namespace = false
  timeout          = 300
  force_update     = true
  cleanup_on_fail  = false
  wait             = true
  recreate_pods    = true

  disable_openapi_validation = false

  set {
    name  = "operatornamespace"
    type  = "string"
    value = var.ws_liberty_operator_namespace
  }

  set {
    name  = "operatortargetnamespace"
    type  = "string"
    value = var.ws_liberty_operator_target_namespace
  }

}

resource "kubernetes_namespace" "websphere_liberty_operator_namespace" {
  count = var.create_ws_liberty_operator_namespace == true ? 1 : 0

  metadata {
    name = var.ws_liberty_operator_namespace
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "helm_release" "websphere_liberty_operator" {
  depends_on = [time_sleep.wait_catalog[0], helm_release.websphere_liberty_operator_group[0], kubernetes_namespace.websphere_liberty_operator_namespace[0]]

  name             = "websphere-liberty-operator-helm-release"
  chart            = "${path.module}/chart/${local.websphere_liberty_operator_chart}"
  namespace        = var.operator_helm_release_namespace
  create_namespace = false
  timeout          = 300
  force_update     = true
  cleanup_on_fail  = false
  wait             = true
  recreate_pods    = true

  disable_openapi_validation = false

  set {
    name  = "operatornamespace"
    type  = "string"
    value = var.ws_liberty_operator_namespace
  }

  set {
    name  = "installplanapprovalconfig"
    type  = "string"
    value = var.ws_liberty_operator_install_plan_approval
  }

  # executed to approve install-plans if var.ws_liberty_operator_install_plan_approval is Manual (if Automatic no change is expected)
  provisioner "local-exec" {
    command     = "${path.module}/scripts/approve-install-plan.sh ${var.ws_liberty_operator_namespace}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

resource "time_sleep" "wait_websphere_liberty_operator" {
  depends_on = [helm_release.websphere_liberty_operator]

  create_duration = local.sleep_time_operator_create
}

##############################################################################
# Confirm websphere operator is operational
##############################################################################

resource "null_resource" "confirm_websphere_liberty_operator_operational" {

  depends_on = [time_sleep.wait_websphere_liberty_operator]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/confirm-wsloperator-operational.sh ${var.ws_liberty_operator_namespace}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

resource "kubernetes_namespace" "websphere_liberty_sampleapp_namespace" {
  depends_on = [null_resource.confirm_websphere_liberty_operator_operational]
  count      = var.install_wslo_sampleapp == true ? 1 : 0

  metadata {
    name = var.wslo_sampleapp_namespace
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

locals {
  websphere_liberty_operator_sampleapp_image_path       = "icr.io/appcafe/open-liberty/samples/getting-started"
  websphere_liberty_operator_sampleapp_image_tag_digest = "latest@sha256:3999aa86f788e601d305896e48a043a91861cdbf71951a1959887151390b3650" # datasource: icr.io/appcafe/open-liberty/samples/getting-started
}

resource "helm_release" "websphere_liberty_operator_sampleapp" {
  depends_on = [kubernetes_namespace.websphere_liberty_sampleapp_namespace[0]]
  count      = var.install_wslo_sampleapp == true ? 1 : 0

  name             = "websphere-liberty-operator-sampleapp-helm-release"
  chart            = "${path.module}/chart/${local.websphere_liberty_operator_sampleapp_chart}"
  namespace        = var.operator_helm_release_namespace
  create_namespace = false
  timeout          = 300
  force_update     = true
  cleanup_on_fail  = false
  wait             = true
  recreate_pods    = true

  disable_openapi_validation = false

  set {
    name  = "application.image.path"
    type  = "string"
    value = local.websphere_liberty_operator_sampleapp_image_path
  }
  set {
    name  = "application.image.version"
    type  = "string"
    value = local.websphere_liberty_operator_sampleapp_image_tag_digest
  }

  set {
    name  = "application.name"
    type  = "string"
    value = var.wslo_sampleapp_name
  }

  set {
    name  = "application.namespace"
    type  = "string"
    value = var.wslo_sampleapp_namespace
  }

}

# waiting for the sample app to be deployed before starting to query for the URL
resource "time_sleep" "wait_sampleapp" {
  depends_on = [helm_release.websphere_liberty_operator_sampleapp[0]]
  count      = var.install_wslo_sampleapp == true ? 1 : 0

  create_duration = local.sleep_time_sampleapp_create
}

data "external" "websphere_liberty_operator_sampleapp_url" {
  depends_on = [time_sleep.wait_sampleapp[0]]
  program    = ["python3", "${path.module}/scripts/get-sampleapp-url.py"]
  query = {
    kubeconfig   = data.ibm_container_cluster_config.cluster_config.config_file_path
    appnamespace = var.wslo_sampleapp_namespace
    appname      = var.wslo_sampleapp_name
    attempts     = 30 # attempts to retrieve the sampleapp url (sleep of 10s between attempts)
  }
}

locals {
  # getting sampleapp_url in a JSON string in the format {"sampleapp_url": "[THE URL]"}
  sampleapp_url_response = jsondecode(data.external.websphere_liberty_operator_sampleapp_url.result.response)
}
