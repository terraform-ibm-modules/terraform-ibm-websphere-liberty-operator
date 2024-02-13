#!/bin/bash

set -e

namespace=$1
fail=false

# This script is designed to verify that WebSphere Liberty operator is fully deployed through its deployment resource wlo-controller-manager

WSLO_DEPLOYMENT_NAME="wlo-controller-manager"

# sleep 60 seconds initially to provide time for each deployment to get created
sleep 60

# Get list of deployments in control plane namespace
DEPLOYMENTS=()
while IFS='' read -r line; do DEPLOYMENTS+=("$line"); done < <(kubectl get deployment "${WSLO_DEPLOYMENT_NAME}" -n "${namespace}" --no-headers | cut -f1 -d ' ')

# Wait for all deployments to come up - timeout after 5 mins
for dep in "${DEPLOYMENTS[@]}"; do
  if ! kubectl rollout status deployment "$dep" -n "${namespace}" --timeout 5m; then
    fail=true
  fi
done

# Fail with some debug prints if issues detected
if [ ${fail} == true ]; then
  echo "Problem detected. Printing some debug info.."
  set +e
  echo "Describe output of ibm-operator-catalog CatalogSource in openshift-marketplace namespace"
  kubectl describe CatalogSource ibm-operator-catalog -n openshift-marketplace
  echo
  echo "Describe output of ibm-websphere-liberty Subscription in ${namespace} namespace"
  kubectl describe Subscription ibm-websphere-liberty -n "${namespace}"
  echo
  echo "List of ${WSLO_DEPLOYMENT_NAME} deployments in ${namespace} namespace"
  kubectl get deployment "${WSLO_DEPLOYMENT_NAME}" -n "${namespace}" -o wide
  echo
  echo "List of pods for ${WSLO_DEPLOYMENT_NAME} deployment in ${namespace} namespace"
  kubectl get pods -n "${namespace}" -o wide
  WSLOPODS=$(kubectl get pods -n "${namespace}" --no-headers | cut -f1 -d ' ' | grep  "${WSLO_DEPLOYMENT_NAME}")
  echo
  echo "Describe output of ${WSLO_DEPLOYMENT_NAME} deployment pods in ${namespace} namespace"
  for pod in "${WSLOPODS[@]}"; do
    kubectl describe pod "${pod}" -n "${namespace}"
  done
  exit 1
fi
