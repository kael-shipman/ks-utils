% KS-ROTATE-DISPLAY(1) Version ::VERSION:: | Rotate display and digitizer in response to physical screen rotations

NAME
====

**ks-rotate-display** — A daemon that watches for changes in screen orientation and rotates the display and digitizer accordingly

SYNOPSIS
========

| **ks-rotate-display** \[**--verbose**] **watch**
| **ks-rotate-display** \[**--verbose**] **enable|disable**
| **ks-rotate-display** \[**--verbose**] \[**-d|--digitizer** _grep-pattern_] _normal|left-up|bottom-up|right-up_
| **ks-rotate-display** \[**--version**]
| **ks-rotate-display** \[**-h|--help**]

DESCRIPTION
===========

The `watch` form starts a daemon that uses `monitor-sensor` from the `iio-sensor-proxy`
package to watch for changes in the screen orientation and change display settings accordingly.

The `enable|disable` form uses user-level systemd to enable or disable the service on login for the
current user.

The command form does the work of actually rotating the display. You can use the command form
on its own without the watch form to just do on-demand rotations. The watch form uses the
command form to execute its adjustments.

Typically you will do something like this to use this service for yourself:

```sh
sudo apt-get install ks-rotate-display
ks rotate-display enable
```

Global Options
--------------

--verbose

:   Outputs debugging information on stderr

Command-Form Options
--------------------

-d, --digitizer

:   Set the grep pattern by which to find digitizer devices to rotate (default: `wacom`)

    This pattern filters results from `xinput -list` using `grep -Ei`. If you don't want to rotate
    the digitizer (or don't have one), you can either leave it at default or set it to an impossible
    value, like `a^$`. Note that this can also be set via the `DIGITIZER_GREP` environment variable.

Hooks
-------

post-rotate - `$KS_PLUGIN_PATH/ks-rotate-display-post-rotate`

:   The post-rotate hook is called (if available and executable) at the end of the command form. It
    receives no arguments, but has access to all of the available environment variables. Use
    `--verbose` in the command form to see available environment variables.

ENVIRONMENT
===========

**DIGITIZER_GREP**

:   Set the grep pattern by which to select digitizers to rotate (see `-d, --digitizer` above in
    "Command-Form Options").

**BUILTIN_REGEXP**

:   An optional regexp (for `grep -E`) for finding the built-in monitor in xrandr's list of outputs.
    Defaults to '^eDP-1'.

**BUILTIN_NAME**

:   An optional name for the built-in monitor. Defaults to whatever is found using `BUILTIN_REGEXP`.

BUGS
====

See GitHub Issues: <https://github.com/kael-shipman/ks-utils/issues>

AUTHOR
======

See GitHub Contributors: <https://github.com/kael-shipman/ks-utils/graphs/contributors>



