% KS-FIX-BANK-CSV(1) Version ::VERSION:: | Add 'credit' and 'debit' columns to a bank csv, and optionally filter out uninteresting dates

NAME
====

**ks-fix-bank-csv** — Add 'credit' and 'debit' columns to a bank csv, and optionally filter out
uninteresting dates

SYNOPSIS
========

| **ks-fix-bank-csv** \[**-d|--date**] \[**-a|--amount**] \[**-s|--start-date**] _input.csv_
| **ks-fix-bank-csv** \[**-h|--help**]

DESCRIPTION
===========

The "help" form outputs this help text.

The function form parses the input file and splits a signed (or parenthesitized) amount column into
debit and credit columns, optionally truncating by start date. Output is written to stdout and can
be redirected accordingly.
 
Command-Form Options
--------------------

-d, --date-column

:   Zero-indexed integer indicating which column contains the transaction date. Default: 0

-a, --amount-column

:   Zero-indexed integer indicating which column contains the transaction amount. Default: 3

-s, --start-date

:   A date before which records will be discarded from the output file. (Must be parsable by javascript Date().) Default: null

BUGS
====

See GitHub Issues: <https://github.com/kael-shipman/ks-utils/issues>

AUTHOR
======

See GitHub Contributors: <https://github.com/kael-shipman/ks-utils/graphs/contributors>



