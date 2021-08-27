#!/bin/bash

set -e

if ! command -v pandoc &>/dev/null; then
    >&2 echo "E: You must have pandoc installed on your path to build documentation."
    exit 1
fi

pkgname="$1"

REPOROOT="."
while ! [ -d "$REPOROOT/docs-src" ]; do
    REPOROOT="$REPOROOT/.."
    if [ "$(readlink -f "$REPOROOT")" == "/" ]; then
        >&2 echo "E: Can't find docs-src! You must be in the repo root or a subdirectory to run"
        >&2 echo "   this script"
        exit 2
    fi
done

n=0
for srcpkg_path in "$REPOROOT"/docs-src/*; do
    srcpkg="$(basename "$srcpkg_path")"
    if [ -n "$pkgname" ] && [ "$pkgname" != "$srcpkg" ]; then
        continue
    fi
    n="$((n + 1))"

    s="$REPOROOT/docs-src/$srcpkg"
    b="$REPOROOT/docs-build/$srcpkg"

    rm -Rf "$b" &>/dev/null || true
    mkdir -p "$b/tmp"

    cp -R "$s"/* "$b/tmp/"

    if grep -rq "::VERSION::" "$b/tmp"; then
        VERSION_FILE="$REPOROOT/pkg-src/generic/$srcpkg/VERSION"
        if ! [ -e "$VERSION_FILE" ]; then
            VERSION_FILE="$REPOROOT/pkg-src/generic/ks-utils/VERSION"
        fi
        VERSION="$(cat "$VERSION_FILE")"
        sed -i "s/::VERSION::/$VERSION/g" $(grep -rl "::VERSION::" "$b/tmp")
    fi

    success=1
    while read -u8 -r -d $'\n' file || [ -n "$file" ]; do
        if echo "$file" | grep -Eq '\.sw[op]$' || ! [ -e "$file" ]; then
          continue;
        fi
        out="$b/${file#$b/tmp/}"
        out="${out%.*}"
        mkdir -p "$(dirname "$out")"
        if ! pandoc --standalone --to man "$file" -o "$out"; then
            success=0
            >&2 echo "Building of docfile $file failed!"
            break
        fi
    done 8< <(find "$b/tmp/" -type f)

    rm -Rf "$b/tmp" &>/dev/null || true

    if [ "$success" -eq 1 ]; then
        echo "Docs successfully built to '$b'"
    fi
done

if [ "$n" -eq 0 ]; then
    if [ -n "$pkgname" ]; then
        >&2 echo "E: '$pkgname' did not match any documentation folders. Please try again."
        exit 1
    else
        >&2 echo "W: No docs found to build."
    fi
fi
