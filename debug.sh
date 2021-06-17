#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${SCRIPTDIR}" || exit
# --vault-password-file ./secrets/vaultSecret.txt
#  --limit="myowncomputer
cmd='ansible-playbook -i debugINV.ini debug.yml -vv'
echo "${cmd}"
eval ${cmd}
