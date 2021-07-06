#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${SCRIPTDIR}" || exit

if [[ ! -e $1 ]]; then >&2 echo "no playbook given" ; exit 1 ; fi
playbook="$1" ; shift

inventories='--inventory ./inventory'
args='--vault-password-file tmp/vault_pass_default --extra-vars "@../dadc_network_config/secrets/secrets.yml"'
color="ANSIBLE_FORCE_COLOR=true"
sedNewlines="| sed 's/\\\\n/\\n/g'" # expands to: | sed '/\\n/\n/g' 

cmd="$color ansible-playbook \"$playbook\" $inventories $args $@ $sedNewlines"
echo "${cmd}"
eval  ${cmd}
