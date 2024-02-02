#!/usr/bin/env bash

set -eE

KUBECONFIG=""
DEBUGFILE="/tmp/getsampleappurl.log"
if [[ -e "${DEBUGFILE}" ]]; then
    rm -f "${DEBUGFILE}"
fi

# jq reads from stdin
function parse_input() {
  eval "$(jq -r '@sh "export KUBECONFIG=\(.KUBECONFIG) APPNAMESPACE=\(.APPNAMESPACE) APPNAME=\(.APPNAME)"')"
}

parse_input

if [[ -z "${KUBECONFIG}" ]] || [[ -z "${APPNAMESPACE}" ]] || [[ -z "${APPNAME}" ]]; then
    echo "[ERROR] one or more input parameter is empty" >> "${DEBUGFILE}"
    echo "[ERROR] one or more input parameter is empty" >&2
    SAMPLEAPPROUTE="ERROR"
else
    # shellcheck disable=SC2129
    echo "[INFO] using KUBECONFIG ${KUBECONFIG}" >> "${DEBUGFILE}"
    # shellcheck disable=SC2129
    echo "[INFO] using APPNAMESPACE ${APPNAMESPACE}" >> "${DEBUGFILE}"
    # shellcheck disable=SC2129
    echo "[INFO] using APPNAME ${APPNAME}" >> "${DEBUGFILE}"

    SAMPLEAPPROUTE="$(oc get routes "${APPNAME}" -n "${APPNAMESPACE}" --no-headers | awk '{print $2}')"

    if [[ -z "${SAMPLEAPPROUTE}" ]]; then
        echo "[ERROR] Error retrieving sample app url from ${APPNAMESPACE}" >> "${DEBUGFILE}"
        SAMPLEAPPROUTE="NOTFOUND"
    fi
fi

jq -n -r --arg sampleapp_url "${SAMPLEAPPROUTE}" '{"sampleapp_url":$sampleapp_url}'
