#!/usr/bin/env bash

set -eE

KUBECONFIG=""
DEBUGFILE="/tmp/getsampleappurl.log"
if [[ -e "${DEBUGFILE}" ]]; then
    rm -f "${DEBUGFILE}"
fi

# default number of attempts to do for the application to start (sleep of 10s)
DEFAULTATTEMPTS="30"

# jq reads from stdin
function parse_input() {
  eval "$(jq -r '@sh "export KUBECONFIG=\(.KUBECONFIG) APPNAMESPACE=\(.APPNAMESPACE) APPNAME=\(.APPNAME) ATTEMPTS=\(.ATTEMPTS)"')"
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

    if [[ -z "${ATTEMPTS}" ]] || [[ "${ATTEMPTS}" == "null" ]]; then
        ATTEMPTS="${DEFAULTATTEMPTS}"
        export ATTEMPTS
    fi
    echo "[INFO] using ATTEMPTS ${ATTEMPTS}" >> "${DEBUGFILE}"

    echo "Waiting for application ${APPNAME} in namespace ${APPNAMESPACE} to be successfully started to get its url (${ATTEMPTS} attempts limit with sleep of 10s)..." >> "${DEBUGFILE}"

    SAMPLEAPPROUTE=""
    loop_count=1
    until [[ ${SAMPLEAPPROUTE} != "" ]] || [[ $loop_count -gt ${ATTEMPTS} ]]
    do
        echo "Running attempt # ${loop_count}/${ATTEMPTS} to get routes of app ${APPNAME} in namespace ${APPNAMESPACE}" >> "${DEBUGFILE}"
        SAMPLEAPPROUTE="$(oc get routes "${APPNAME}" -n "${APPNAMESPACE}" --no-headers | awk '{print $2}')"
        if [[ ${SAMPLEAPPROUTE} != "" ]]; then
            echo "Sample app url found ${SAMPLEAPPROUTE} at attempt # ${loop_count}/${ATTEMPTS}" >> "${DEBUGFILE}"
            break
        else
            echo "Sample app url not found at attempt # ${loop_count}/${ATTEMPTS}" >> "${DEBUGFILE}"
            if [[ $loop_count -gt ${ATTEMPTS} ]]; then
                echo "Reached max number of attempts ${ATTEMPTS}"
                break
            else
                echo "Sleeping for 10s before attempting again" >> "${DEBUGFILE}"
                sleep 10
                loop_count=$((loop_count+1))
            fi
        fi
    done

    if [[ -z "${SAMPLEAPPROUTE}" ]]; then
        echo "[ERROR] Error retrieving sample app url from ${APPNAMESPACE}" >> "${DEBUGFILE}"
        SAMPLEAPPROUTE="NOTFOUND"
    fi
fi

echo -n '{"sampleapp_url":"'"${SAMPLEAPPROUTE}"'"}'
