#!/usr/bin/env bash # only for formatting of file, this file should be sourced only

if [[ ! -z $jenkinsbashlibsourced ]] ; then return ; fi

JENKINSBASHLIB_SCRIPTDIR="$( dirname "${BASH_SOURCE[0]}" )"
>&2 echo -e "sourcing jenkinsbashlib.sh in ${SCRIPTDIR}"
jenkinsbashlibsourced="yes"
source "${JENKINSBASHLIB_SCRIPTDIR}/../common/commonbashlib.sh"


export JENKINS_SERVER="localhost:8090"
export HTTPS_Jenkins="http://${JENKINS_SERVER}"
export APIV=""
export JENKINS_URL="${HTTPS_Jenkins}${APIV}"
export jenkinsuser=unknown
export jenkinspassword=unknown


function jenkins_curlGETWithToken() {
    # $1: token
    if [[ -z $1 ]]; then exit 1 ; fi
    local token=$1 ; shift

    $CURLBASE -X GET \
    --user ${jenkinsuser}:${token} \
    "${JENKINS_URL}/$*"
}
function jenkins_curlPOSTWithTokenWithoutData() {
    # $1: token
    if [[ -z $1 ]]; then exit 1 ; fi
    local token=$1 ; shift

    $CURLBASE -X POST \
    --user ${jenkinsuser}:${token} \
    "${JENKINS_URL}/$*"
}
function jenkins_curlPOSTWithToken() {
    # $1: token
    # $2: path to json
    if [[ -z $1 ]]; then exit 1 ; fi
    if [[ -z $2 ]]; then exit 2 ; fi
    local token=$1 ; shift
    local jsonfile=$2 ; shift

    $CURLBASE -X POST \
    --user ${jenkinsuser}:${token} \
    -d "@$jsonfile" \
    "${JENKINS_URL}/$*"
}



>&2 echo -e "done jenkinsbashlib.sh"