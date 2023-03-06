% GIT-PRUNE-LOCAL(1) Version ::VERSION:: | A git plugin to clean out unlinked local branches

NAME
====

**git-prune-local** — A git plugin to clean out local branches whose remotes have been deleted

SYNOPSIS
========

| **git prune-local** \[**options**]
| **git prune-local** \[**-h**|**--help**]
| **git prune-local** \[**-v**|**--version**]

DESCRIPTION
===========

First identifies all local branches which may be cleaned up according to the mode:

* In normal mode, uses branches that are linked to a remote branch that has been deleted.
* In "aggressive" mode, uses all local branches that are not currently linked to a live upstream
  branch (this includes local branches that were _never_ linked to an upstream branch).

Once the set of operable branches is identified, the utility iterates through the branches and
either deletes them (if `--force|-f` is passed) or asks if you would like to delete each one
(default, or if `--interactive|-i` is passed).

If used from a git repo, operates on the given repo. If used from a workspace with several git
repos, iterates through each child repo and operates on each one.

Options
--------------

-a, --all, --aggressive

:   Aggressive mode: Instead of using git branch -v, list every local branch that doesn't have a
    corresponding branch in a remote

-i, --interactive

:   Ask before deleting branches (this is the default behavior)

-f, --force

:   Don't ask before deleting branches

-o, --normal

:   Normal mode: The opposite of aggressive mode. (Uses git branch -v instead of doing a
    branch-by-branch comparison.)

-q, --quiet

:   Alias of --force"

BUGS
====

See GitHub Issues: <https://github.com/kael-shipman/ks-utils/issues>

AUTHOR
======

See GitHub Contributors: <https://github.com/kael-shipman/ks-utils/graphs/contributors>


