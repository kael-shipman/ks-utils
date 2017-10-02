#!/bin/bash

argisset() {
  ARG=$1
}
  


MNT=/media/kael/Nikon\ D600
SRC="$MNT/DCIM"

if [ ! -e "$SRC" ]; then
  echo -n 'Card not mounted. Mounting....'
  mount "$MNT"
  if [ $? != 0 ]; then
    echo 'Freak out! Folder didn'"'"'t mount right :('
    echo
    exit
  else
    echo "DONE."
  fi
else
  echo "Card already mounted."
fi

if [ "$1" == --preserve ]; then
  CMD='cp'
  ACTION='Copying'
else
  CMD='mv'
  ACTION='Moving'
fi

TARG="$HOME/Pictures/Staging"
if [ ! -e "$TARG" ]; then
  echo -n "Photo 'Staging' directory not yet created. Creating...."
  mkdir "$TARG"
  STATUS=$?
  if [ $STATUS != 0 ]; then
    echo "FAILED! Aborting :("
    umount "$MNT"
    exit $STATUS
  else
    echo "Done."
  fi
fi

echo
echo "$ACTION...."
$CMD "$SRC"/*/* $TARG/

STATUS=$?

if [ $STATUS != 0 ]; then
  echo 'Couldn'"'"'t transfer photos. Aborting :(.'
else
  echo 'Files successfully transfered!'
fi

echo -n 'Unmounting...'
umount "$MNT"
if [ $? != 0 ]; then
  echo 'FAILED! Unmount card manually!'
else
  echo 'DONE.'
fi

echo

exit $STATUS

