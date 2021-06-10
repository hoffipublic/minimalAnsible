#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${SCRIPTDIR}" || exit
cmd='ansible-playbook -i debugINV.yml debug.yml -vv --limit="localhost"'
echo "${cmd}"
eval ${cmd}
