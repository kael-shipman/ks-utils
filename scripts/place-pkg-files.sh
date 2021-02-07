#!/bin/bash

pkgname="$1"
target="$2"
pkgtype="$3"

# Build and move docs
man="$target/usr/local/share/man"
mkdir -p "$man"
./scripts/docs-build.sh "$pkgname"
mv "./docs-build/$pkgname"/* "$man/"

# Move package files
if [ "$pkgname" == "ks-rotate-display" ]; then
    mkdir -p "$target/usr/local/bin"
    sudo rsync -aHAXog src/usr/local/bin/ks-rotate-display "$target/usr/local/bin/"
else
    sudo rsync -aHAXog --exclude ks-rotate-display src/* "$target"/
fi
