#!/bin/bash

pkgname="$1"
target="$2"
pkgtype="$3"

sudo rm -Rf docs-build/*
man="$target/usr/local/share/man"
mkdir -p "$man"

if [ "$pkgname" == "ks-rotate-display" ]; then
    # Handling ks-rotate-display separately

    # Build and move docs
    ./scripts/docs-build.sh "$pkgname"
    mv "./docs-build/$pkgname"/* "$man/"

    mkdir -p "$target/usr/local/bin"
    sudo rsync -aHAXog src/usr/local/bin/ks-rotate-display "$target/usr/local/bin/"
else
    # Bundling everything else into ks-utils

    # Build and move docs
    ./scripts/docs-build.sh
    rm -Rf ./docs-build/ks-rotate-display
    rsync -rlu ./docs-build/*/* "$man/"

    sudo rsync -aHAXog --exclude ks-rotate-display src/* "$target"/
fi

