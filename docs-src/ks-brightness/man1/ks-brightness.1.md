% KS-BRIGHTNESS(1) Version ::VERSION:: | Increment, decrement or set display brightness

NAME
====

**ks-brightness** - Increment, decrement or set display brightness

SYNOPSIS
========

| **ks-brightness** \[**-p|--path _path to brightness file_**] \[**--verbose**] _up|down_
| **ks-brightness** \[**-p|--path _path to brightness file_**] \[**--verbose**] _numeric value_
| **ks-brightness** \[**--version**]
| **ks-brightness** \[**-h|--help**]

DESCRIPTION
===========

The "help" form outputs this help text.

The 'up' or 'down' form increments or decrements the current display brightness by 200 points.

The 'numeric value' form sets the display brightness to the given numeric value.
 
Command-Form Options
--------------------

-p, --path

:   The path to your current brightness file. default: `/sys/class/backlight/intel_backlight/brightness`

BUGS
====

See GitHub Issues: <https://github.com/kael-shipman/ks-utils/issues>

AUTHOR
======

See GitHub Contributors: <https://github.com/kael-shipman/ks-utils/graphs/contributors>


