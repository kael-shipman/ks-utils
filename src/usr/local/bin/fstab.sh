#!/bin/bash

function echo_usage() {
    nm=`basename "$0"`
    echo
    echo "$nm -- manage a standard, backed-up fstab over the top of a pre-existing, machine-specific fstab"
    echo
    echo "  $nm view"
    echo "  $nm (-p|--path) install"
    echo "  $nm uninstall"
    echo "  $nm (-p|--path) add [entry]"
    echo "  $nm (-p|--path) remove [UUID|device|path]"
    echo
    echo "OPTIONS"
    echo
    echo "  -p [PATH]|--path=[PATH]   Path to your fstab overlay file"
    echo
}

cmd=
str=
filepath=~/"Configuration Files/linux/etc/fstab"

while test $# -gt 0; do
    case $1 in
        -h|--help)
            echo_usage
            exit 0
        ;;

        -p)
            shift
            filepath="$1"
            shift
        ;;

        --path=*)
            filepath="$1"
            filepath="${filepath:7}"
            shift
        ;;

        *)
            if [ -z "$cmd" ]; then
                cmd="$1"
                cmd="${cmd,,}"
                if [ "$cmd" != 'view' ] && \
                   [ "$cmd" != 'install' ] && \
                   [ "$cmd" != 'uninstall' ] && \
                   [ "$cmd" != "add" ] && \
                   [ "$cmd" != "remove" ]; then

                    >&2 echo "ERROR: You've passed an unknown command, \`$cmd\`. See \`$0 -h\` for more information."
                    exit 1
                fi
            else
                if [ -z "$str" ]; then
                    str="$1"
                else
                    str="$str $1"
                fi
            fi
            shift
        ;;
    esac
done

if [ -z "$cmd" ]; then
    echo_usage
    exit 1
fi

resolver=`get-resolver.sh`
if [ -z "$resolver" ]; then
    >&2 echo "Couldn't find a readlink or realpath alternative on your system. Exiting."
    exit 1
fi

filepath="`$resolver "$filepath"`"

#echo
#echo "  CMD:           $cmd"
#echo "  FILEPATH:      $filepath" 
#echo "  STR:           $str"
#echo
#exit

case "$cmd" in
    view)
        cat /etc/fstab

    ;;

    install)
        if [ ! -e /etc/fstab.base ]; then
           sudo cp /etc/fstab /etc/fstab.base
        fi

        echo
        echo "Installing $filepath on top of /etc/fstab...."
        echo

        sudo sh -c 'cat /etc/fstab.base "'"$filepath"'" > /etc/fstab'

        if [ "$?" -eq 0 ]; then
            echo "  Success! fstab installed."
            echo
            exit 0
        else
            echo "  Failed :(. Please fix manually."
            exit 1
        fi

    ;;

    uninstall) 
        if [ -e /etc/fstab.base ]; then
            echo
            echo "Uninstalling fstab overlay (reverting to fstab base)"
            echo

            sudo sh -c 'cat /etc/fstab.base > /etc/fstab'
            sudo rm /etc/fstab.base 2>/dev/null

            echo "Done."
            echo
            exit 0
        else
            echo
            echo "fstab overlay not installed. Nothing to do."
            echo
            exit 0
        fi

    ;;

    add)
        entry="$str"

        # Validate entry
        if [ `echo "$entry" | egrep -c '^((UUID=[a-fA-F0-9-]{9,42})|/dev(/[^/ ]+)+) +/[^/ ]*(/[^/ ]+)* +[a-zA-Z0-9_-]+ +[^ ]+ +[0-9] +[0-9] *$'` -eq 0 ]; then
            echo
            echo "  Hm.... It looks like your new entry has errors. Check it and make sure this is what you want to add:"
            echo
            echo "    \`$entry\`"
            echo
            read -n 1 -p "  Should we proceed with adding this entry? (May cause boot problems!) [y,N]: " ANS
            echo
            echo
            
            if [ "${ANS,,}" != 'y' ]; then
                echo "Exiting."
                exit 1
            fi
        fi

        # Do automount check
        if [ `echo "$entry" | grep -c noauto` -eq 0 ]; then
            echo
            echo "  It looks like you're expecting this entry to auto-mount at boot. Sure you want to do this? (NOTE: Automounting"
            read -n 1 -p "  can break your boot if the device is not available at boot.) [y,N]: " ANS
            echo
            if [ "${ANS,,}" != 'y' ]; then
                echo "Exiting."
                exit 1
            fi
        fi

        # Do duplicate check
        check1=`echo "$entry" | egrep -o '^[^ ]+'`
        check1=`grep "^$check1" /etc/fstab 2>/dev/null`
        check2=`echo "$entry" | egrep -o ' /[^/ ]*(/[^/ ]+)* '`
        check2=`grep "$check2" /etc/fstab 2>/dev/null`

        if [ ! -z "$check1" ] || [ ! -z "$check2" ]; then
            echo
            echo "  ERROR! It looks like you're trying to add a duplicate entry. Here's the conflicting entry:"
            echo
            echo "    $check1""$check2"
            echo
            exit 1
        fi

        # If all checks are good, add the entry
        echo "$entry" >> "$filepath"
        $0 -p "$filepath" install >/dev/null
        if [ "$?" -gt 0 ]; then
            exit "$?"
        else
            echo
            echo "  Entry successfully added."
            echo
            exit 0
        fi

    ;;

    remove)
        entry=$(echo "$str" | sed 's/\//\\\//g')

        # If entry not found, exit
        if [ `grep -c "$str" "$filepath"` -eq 0 ]; then
            echo
            echo "  Entry not found. Nothing to do."
            echo
            exit
        fi

        # Otherwise, remove it
        sed -i "/$entry/d" "$filepath"
        if [ "$?" -gt 0 ]; then
            echo
            echo "ERROR: Something went wrong extracting the entry with sed :(."
            echo
            exit 1
        fi

        # Then reinstall
        $0 -p "$filepath" install >/dev/null
        if [ "$?" -gt 0 ]; then
            exit 1
        else
            echo
            echo "  Entry successfully removed."
            echo
            exit 0
        fi
    ;;

esac

