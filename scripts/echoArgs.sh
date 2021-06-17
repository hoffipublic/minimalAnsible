#!/usr/bin/env bash

if [[ ! -z $1 ]]; then echo -n "'$1'" ; shift ; fi
for var in "$@"; do
    echo -n ", '$var'"
done
echo