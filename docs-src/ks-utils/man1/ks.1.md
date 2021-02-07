% KS(1) Version ::VERSION:: | Kael's Personal Utility Script

NAME
====

**ks** — A utility/control script for various functions

SYNOPSIS
========

| **ks** \[**global options**] _command_ \[**command options**]
| **ks** \[**-h**|**--help**]
| **ks** \[**-v**|**--version**]

DESCRIPTION
===========

Provides a basic but extensible CLI for accessing functionality pertinent to the things that I do
on a normal basis. Comes loaded with a few essential commands, but also provides a small framework
for authoring plugins. Plugins have access to the basic library functions detailed below in the
`Plugins` section.

The essential built-in commands are the following:

list-commands \[**-r**|**--raw**]

:    Lists all available commands, including plugins

     If the `-r|--raw` option is passed, outputs a `\n`-delimited list of command names with no
     extra text or whitespace.

Global Options
--------------

(none)

Plugins
-------

Plugins are very easy to develop, and there are no restrictions on what they can do.

To create a plugin, simply drop an executable file into the `$KS_PLUGIN_PATH` (see below) and
rename it to start with `ks-`. That's it! `ks` will make note of its existence in the native
`list-commands` command, and you can use it by calling `ks [name-without-prefix]`. `ks` will pass
any unrecognized arguments on to your plugin, and it will also export its own internal variables
and functions for use by your plugin. (If your plugin is in bash, it can use those functions
natively.  If not, you may still be able to access them, depending on the capacities of the
language you've chosen to author your plugin in.)

Regardless, `ks` makes the following functions available to whomever chooses to use them:

(Not yet documented)


ENVIRONMENT
===========

**KS_PLUGIN_PATH**

:   The path at which ks plugins are stored. Defaults to `/usr/bin/local/`.

BUGS
====

See GitHub Issues: <https://github.com/kael-shipman/ks-utils/issues>

AUTHOR
======

See GitHub Contributors: <https://github.com/kael-shipman/ks-utils/graphs/contributors>


