#!/bin/bash

# does ignore host_vars/ and group_vars/ inside roles!!!

function finish() { set +x ; }
trap finish EXIT

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPODIR=$(dirname "$SCRIPTDIR")
BASEDIR=$(dirname "$REPODIR")

configDir="$BASEDIR/externalConfig"

if [ -z "$1" ] || { [ "$1" != "--list" ] && [ "$1" != "--host" ]; }; then >&2 echo "1st arg has to to be either --list or --host" ; exit 127 ; fi
if [ "$1" = "--host" ] && [ -z "$2" ] || [ "$(printf '%s' "$2" | cut -c1)" = "-" ]; then >&2 echo "hostname missing for --host argument" ; exit 127 ; fi

yaml=""
if [ "$2" = "-y" ] || [ "$2" = "--yaml" ] || [ "$3" = "-y" ] || [ "$3" = "--yaml" ]; then
    yaml="--yaml"
fi

set -e

if [ ! -d "$configDir" ]; then
    git clone "URL" "$configDir"
else
    pushd "$configDir" > /dev/null 2>&1
    # git stash > /dev/null
#    git pull > /dev/null 2>&1
    # git stash pop > /dev/null 2>&1
    popd > /dev/null 2>&1
fi

if [ "$1" = "--list" ]; then
    ansible-inventory --inventory "${configDir}/hosts" --inventory "${configDir}/host_vars" --inventory "${configDir}/group_vars" --list $yaml      2> /dev/null
elif [ "$1" = "--host" ]; then
    ansible-inventory --inventory "${configDir}/hosts" --inventory "${configDir}/host_vars" --inventory "${configDir}/group_vars" --host "$2" $yaml 2> /dev/null
fi
