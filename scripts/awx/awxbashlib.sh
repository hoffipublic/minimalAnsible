#!/usr/bin/env bash

export AWX_SERVER="localhost:8043"
export HTTPS_AWX="https://${AWX_SERVER}"
export APIV="api/v2"
export AWX_URL="${HTTPS_AWX}/${APIV}"
export CURLBASE="curl -L -s -S -k"
export awxuser=unknown
export awxpassword=unknown

function awx_resources() {
    $CURLBASE "${AWX_URL}/api/v2/"
}

function awxcurlGETunauth() {
    $CURLBASE $AWX_URL/$*
}
function awxcurlGETmanual() {
    $CURLBASE -u $awxuser:$awxpassword $AWX_URL/$*
}
function awxcurlPOSTmanual() {
    $CURLBASE -u $awxuser:$awxpassword -X POST -H "Content-Type: application/json" $AWX_URL/$*    
}

# https://www.ansible.com/blog/summary-of-authentication-methods-in-red-hat-ansible-tower
function awx_curlGETWithToken() {
    # $1: token
    if [[ -z $1 ]]; then exit 1 ; fi
    local token=$1 ; shift

    $CURLBASE -X GET \
    -H "Authorization: Bearer $token" \
    "${AWX_URL}/$*"
}
function awx_curlPOSTWithToken() {
    # $1: token
    # $2: path to json
    if [[ -z $1 ]]; then exit 1 ; fi
    if [[ -z $2 ]]; then exit 2 ; fi
    local token=$1 ; shift
    local jsonfile=$2 ; shift

    $CURLBASE -X POST \
    -H "Content-Type: application/json" -H "Authorization: Bearer $token" \
    -d "@$jsonfile" \
    "${AWX_URL}/$*"
}

# https://www.ansible.com/blog/summary-of-authentication-methods-in-red-hat-ansible-tower
function awx_csrftoken() {
    # curl -L -s -S -k -c - https://localhost:8043/api/login/ | sed -n -E "s/^.*csrftoken\t([^ ]*)$/--cookie csrftoken='\1'/p"
    $CURLBASE -c - "${HTTPS_AWX}/api/login/" \
        | sed -n -E "s/^.*csrftoken\t([^ ]*)$/\1/p"
}
function awx_login_sessionid() {
    local csrftoken=$(awx_csrftoken)
    $CURLBASE -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
    --referer "${HTTPS_AWX}/api/login/" \
    -H "X-CSRFToken: $csrftoken" \
    --data "username=$awxuser&password=$awxpassword" \
    --cookie "csrftoken=$csrftoken" \
    $HTTPS_AWX/api/login/ -D - -o /dev/null \
        | sed -n -E "s/^Set-Cookie: sessionid=(.*); expires.*$/\1/p"
}
