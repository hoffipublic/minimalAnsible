#!/usr/bin/env bash
function finish() { set +x ; }
trap finish EXIT
SCRATCH_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e # exit on error
>&2 echo "read shared bashlibs .."
source "${SCRATCH_SCRIPTDIR}/awx/awxbashlib.sh"
>&2 echo -e "reading shared bashlibs done.\n"


awxuser=awx
awxpassword=awx


awxtoken="JViTPB7aoUysBVJ2Jb3dsf6rjkGWz2"
# awxrefre jEIJAR5KO9fBGicv5LhQEP76XRVOYY

set -x

# curl -L -s -S -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${awxtoken}" \
#   ${HTTPS_Jenkins}/api/v2/job_templates/hoffijob/launch/
awx_curlPOSTWithToken $awxtoken <(echo '{"extra_vars": {"foo": "bar"} }') "job_templates/hoffijob/launch/"



>&2 echo -e "\nOK: Finished"