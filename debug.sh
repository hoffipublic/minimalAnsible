#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${SCRIPTDIR}" || exit
# --vault-password-file ./secrets/vaultSecret.txt
cmd='ansible-playbook -i debugINV.ini debug.yml -vv --limit="localhost"'
echo "${cmd}"
eval ${cmd}
