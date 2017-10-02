#!/bin/bash

if command -v readlink >/dev/null 2>&1; then
    resolver='readlink -f'
else
    if command -v realpath >/dev/null 2>&1; then
        resolver='realpath'
    else
        echo
        echo "ERROR: No readlink or realpath binaries found! Migrate-me requires"
        echo "one of these programs to resolve absolute URLs. Please figure out"
        echo "how to install one (preferrably readlink). Exiting :(."
        echo
        exit 1
    fi
fi

echo "$resolver"


