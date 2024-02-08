#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to destroy the SLZ ROKS Cluster, which was provisioned as a            ##
## prerequisite for the WAS extension that is published to the catalog                                                ##
########################################################################################################################

set -e

TERRAFORM_SOURCE_DIR="tests/resources"
TF_VARS_FILE="terraform.tfvars"

(
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Destroying prerequisite SLZ ROKS Cluster .."
  terraform destroy -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  echo "Post-validation complete successfully"
)
