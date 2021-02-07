#!/bin/bash

set -e

if ! command -v pandoc &>/dev/null; then
    >&2 echo "E: You must have pandoc installed on your path to build documentation."
    exit 1
fi

pkgname="$1"
if [ -z "$pkgname" ]; then
    >&2 echo "E: Error building docs. Package name must be supplied as first argument"
    exit 1
fi

REPOROOT="."
while ! [ -d "$REPOROOT/docs-src" ]; do
    REPOROOT="$REPOROOT/.."
    if [ "$(readlink -f "$REPOROOT")" == "/" ]; then
        >&2 echo "E: Can't find docs-src! You must be in the repo root or a subdirectory to run"
        >&2 echo "   this script"
        exit 2
    fi
done

s="$REPOROOT/docs-src/$pkgname"
b="$REPOROOT/docs-build/$pkgname"

rm -Rf "$b" &>/dev/null || true
mkdir -p "$b/tmp"

cp -R "$s"/* "$b/tmp/"

if grep -rq "::VERSION::" "$b/tmp"; then
    VERSION="$(cat "$REPOROOT/pkg-src/generic/$pkgname/VERSION")"
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

