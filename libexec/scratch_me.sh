#!/bin/sh -ex
#make a scratchfile
td=${HOME}/.scratch
mkdir -p  $td
nau=$(date +"%s")
fname=$td/scratchme.$nau
touch   $fname
chmod 700 $fname
exec vi $fname
