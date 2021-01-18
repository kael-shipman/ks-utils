#!/bin/bash

profile="passport"
if [ ! -z "$1" ]; then
    profile="$1"
fi

case "$profile" in
    passport)
        drv=/media/kael/Kael\ Backup
        prf=passport
    ;;

    kabuum)
        drv=/media/kael/kabuum
        prf=kabuum
    ;;

    *)
        >&2 echo 
        >&2 echo "ERROR: Unknown profile '$profile'"
        >&2 echo
        exit 1
    ;;
esac

echo "Mounting drive...."
mount "$drv"
if [ "$?" -gt 0 ]; then
    >&2 echo
    >&2 echo "ERROR: Drive failed to mount! Exiting :(."
    >&2 echo
    exit 1
fi

unison "$prf"

umount "$drv"

if [ "$?" -gt 0 ]; then
    >&2 echo
    >&2 echo "DRIVE FAILED TO UNMOUNT. Please unmount manually before removing."
    >&2 echo
else
    echo
    echo "Drive umounted -- safe to remove."
    echo
fi

