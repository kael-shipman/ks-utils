#!/bin/bash

sub=0
current=`pwd`
executable="$(readlink -f "$0")"

while test $# -gt 0; do
  case $1 in
    -h|--help)
      echo "Sorry, no help yet."
      exit 0
      ;;

    -s|--sub-request)
     sub=1
     shift
     ;;

    -d|--dir)
      shift
      current=$1
      shift
      ;;
   
    *)
      if [ "${1:0:1}" == "-" ]; then
        echo 'Argument `'"$1"'` unknown!'
        echo_usage
        exit 1
      fi
      SCRIPTS[${#SCRIPTS[@]}]=$1
      shift
      ;;

  esac
done


if [ $sub -eq 0 ]; then echo "Checking for changes in all directories below $current..."; fi
changes=0

ds=`echo $current/*/`

if [ "$ds" != "$current/"'*/' ]; then

    for d in $ds; do
      # Don't descend into 3rd-party vendor folders
      if [ "$(basename "$d")" == 'vendor' ]; then
          continue
      fi

      if ! cd "$d"; then
          >&2 echo "E: Couldn't descend into directory '$d'. Skipping."
          continue
      fi

      repo="$d"

      if [ -d .git ]; then
        # If we're in a headless commit, then it's probably a submodule dependency and we shouldn't worry about it
        s=`git status`
        if [ `echo "$s" | grep -c 'not currently on a branch'` -gt 0 ]; then
            continue
        fi

        # Fetch origin
        git fetch origin > /dev/null


        # Now check the status
        s=`git status`

        # If it doesn't indicate that it's "clean" it has changes to address
        if [ `echo "$s" | grep -c 'clean'` -eq 0 ]; then
          echo "  '$repo' has changes you need to address"
          changes=1

        # If it is clean, see if it's ahead or behind
        else
          if [ `echo "$s" | grep -c 'behind'` -gt 0 ]; then
            read -n 1 -p "  '$repo' is behind origin. Shall we pull? [Y,n] " pull
            if [ "${pull,,}" != 'n' ]; then
                git pull
                if [ "$?" == 0 ]; then echo "Done updating."
                else
                    echo
                    echo "There were errors! Exiting at '$repo'"
                    echo
                    exit 1
                fi
            fi
          fi

          if [ `echo "$s" | grep -c 'ahead'` -gt 0 ]; then
            echo "  '$repo' is ahead of origin. You may want to push it."
          fi
        fi

      fi

      "$executable" -s
      if [ "$?" -gt 0 ]; then changes=1; fi

      cd ../
    done

fi

if [ $sub -eq 0 ]; then
    if [ $changes == 0 ]; then echo "All repositories clean! Exiting.";
    else echo "Done."; fi
    echo
    exit 0
fi

exit $changes

