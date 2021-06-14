#!/usr/bin/env bash
function finish() { set +x ; }
trap finish EXIT
SCRATCH_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e # exit on error
>&2 echo "read shared bashlibs .."
source "${SCRATCH_SCRIPTDIR}/jenkins/jenkinsbashlib.sh"
source "${SCRATCH_SCRIPTDIR}/awx/awxbashlib.sh"
>&2 echo -e "reading shared bashlibs done.\n"


awxuser=awx
awxpassword=awx
jenkinsuser=hoffi


# token JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2
awxtoken="JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2"
# awxrefre jEIJAR5KO9fBGicv5LhQEP76XRVOYY
jenkinstoken="11f4156bed98239a76a889a50e6df1e7d3" # hoffitoken

set -x

jenkins_curlPOSTWithTokenWithoutData $jenkinstoken "job/hoffi/job/minimalAnsible/build"


# curl -L -s -S -k -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2' \
#   https://localhost:8043/api/v2/job_templates/hoffijob/launch/
awx_curlPOSTWithToken $awxtoken <(echo '{"extra_vars": {"foo": "bar"} }') "job_templates/hoffijob/launch/"



>&2 echo -e "\nOK: Finished"