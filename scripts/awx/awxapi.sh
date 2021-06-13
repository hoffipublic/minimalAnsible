#!/usr/bin/env bash
function finish() { set +x ; }
trap finish EXIT
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e # exit on error
source "${SCRIPTDIR}/awxbashlib.sh"

awxuser=awx
awxpassword=awx


# token JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2
token="JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2"
# refre jEIJAR5KO9fBGicv5LhQEP76XRVOYY

set -x
# awx_curlGETWithToken $token "hosts/"

# curl -L -s -S -k -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2' \
#   https://localhost:8043/api/v2/job_templates/hoffijob/launch/
awx_curlPOSTWithToken $token <(echo '{"extra_vars": {"foo": "bar"} }') "job_templates/hoffijob/launch/"


>&2 echo -e "\n\nOK: Finished"