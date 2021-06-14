#!/usr/bin/env bash # only for formatting of file, this file should be sourced only

if [[ ! -z $commonbashlibsourced ]] ; then return ; fi
COMMONBASHLIB_SCRIPTDIR="$( dirname "${BASH_SOURCE[0]}" )"
>&2 echo -e "sourcing commonbashlib.sh in $COMMONBASHLIB_SCRIPTDIR"
commonbashlibsourced="yes"

export CURLBASE="curl -L -s -S -k"

>&2 echo -e "done commonbashlib.sh"