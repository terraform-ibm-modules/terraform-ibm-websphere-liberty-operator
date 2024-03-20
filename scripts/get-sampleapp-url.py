#!/usr/bin/env python3

#########################################################################################################
# Script to retrieve the websphere sample app url from the openshift routes in the sample app namespace
#########################################################################################################

import json
import logging
import os
import subprocess
import sys
import time

input = sys.stdin.read()
input_json = json.loads(input)

# json response format
json_response = {"response": ""}

# debugging file init
DEBUGFILE = "/tmp/getsampleappurl.log"
if os.path.exists(DEBUGFILE):
    os.remove(DEBUGFILE)

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(DEBUGFILE)],
)


# method to retrieve json attribute - returns the default value if the key doesn't exist or exists but it is null
def get_attribute(data, attribute, default_value):
    return data.get(attribute) or default_value


def returnFatalError(message, mustExit=False):
    message = {"error": "Error: " + message, "sampleapp_url": sampleapp_url}
    returnResponse(message, True)
    if mustExit:
        sys.exit(1)


# return the string on the standard error
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


# formats the string returned as response
# if isError is true the output of the string is returned on sterr instead of stout
def returnResponse(responseObject, isError=False):
    json_response_formatted = json.dumps(responseObject, indent=2)
    logging.info("returnResponse - response JSON content:")
    logging.info(json_response_formatted)
    json_response["response"] = json.dumps(responseObject, indent=None)
    json_response_string = json.dumps(json_response, indent=None)
    if isError:
        eprint(json_response_string)
    else:
        print(json_response_string)


# default values
SLEEP = 10  # seconds to sleep
DEFAULTRETRIES = 30  # 30 x 5 = 30 secs = 5 mins

# reset input variables
KUBECONFIG = ""
APPNAMESPACE = ""
APPNAME = ""
ATTEMPTS = 0

input_json_formatted = json.dumps(input_json, indent=2)

logging.info("input JSON content:")
logging.info(input_json_formatted)

# setting input variables
KUBECONFIG = get_attribute(input_json, "kubeconfig", "")
APPNAMESPACE = get_attribute(input_json, "appnamespace", "")
APPNAME = get_attribute(input_json, "appname", "")
ATTEMPTS = get_attribute(input_json, "attempts", 0)

logging.info("Input parameters:")
logging.info(f"KUBECONFIG {KUBECONFIG}")
logging.info(f"APPNAMESPACE: {APPNAMESPACE}")
logging.info(f"APPNAME: {APPNAME}")
logging.info(f"ATTEMPTS: {ATTEMPTS}")

# checking empty values
if not (len(APPNAMESPACE.strip()) and len(APPNAME.strip())):
    message = "One or more mandatory parameter is empty"
    logging.error(message)
    returnFatalError(message)

if ATTEMPTS == 0:
    ATTEMPTS = DEFAULTRETRIES
    logging.info(f"Input ATTEMPTS parameter is 0 so using default value {ATTEMPTS}")

# default value for the sample app url
sampleapp_url = "NOTFOUND"
for counter in range(ATTEMPTS):
    if counter == (ATTEMPTS - 1):
        # if attempts are over limit giving up
        logging.error(
            f"attempt {counter + 1} reached max amount of retries {ATTEMPTS} - giving up"
        )
        logging.error(
            f"Error retrieving sample app {APPNAME} url in namespace {APPNAMESPACE}"
        )
        emsg = f"Error retrieving sample app {APPNAME} url in namespace {APPNAMESPACE}"
        logging.error(emsg)
        returnFatalError(emsg)

    # Getting status of sdnlb LB
    logging.info(
        f"Attempt {counter + 1} / {ATTEMPTS} - Retrieving sample app {APPNAME} url in namespace {APPNAMESPACE}"
    )
    try:
        oc_result = subprocess.run(
            ["oc", "get", "routes", "-n", APPNAMESPACE, APPNAME, "-o", "json"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            encoding="utf-8",
        )
        logging.debug(oc_result.stdout)
        app_routes = json.loads(oc_result.stdout)
        logging.info(f"App routes: {app_routes}")
        status = app_routes.get("status", "")
        if status != "":
            logging.info(f"Status: {status}")
            ingress = status.get("ingress", "")
            if ingress != "":
                logging.info(f"Ingress: {ingress}")
                route = ingress[0].get("host")
                logging.info(f"Route: {route}")
                if route != "":
                    msg = f"Attempt {counter + 1} / {ATTEMPTS} - Found route {route} for sample app {APPNAME} routes in namespace {APPNAMESPACE}"
                    sampleapp_url = route
                    logging.info(msg)
                    break

    except subprocess.CalledProcessError:
        emsg = f"Attempt {counter + 1} / {ATTEMPTS} - error in getting sample app {APPNAME} routes in namespace {APPNAMESPACE}"
        logging.error(emsg)

    msg = f"Attempt {counter + 1} / {ATTEMPTS} - route for sample app {APPNAME} routes in namespace {APPNAMESPACE} not found yet"
    logging.info(msg)
    logging.info(f"Sleeping for {SLEEP} seconds before having a new attempt")
    time.sleep(SLEEP)

response = {"sampleapp_url": sampleapp_url}
logging.debug(json.dumps(response, indent=2))

returnResponse(response)
