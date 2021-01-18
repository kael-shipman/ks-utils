#!/bin/bash

pkgname="$1"
target="$2"
pkgtype="$3"

sudo rsync -aHAXog src/* "$target"/
