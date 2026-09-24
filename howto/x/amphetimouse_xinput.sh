#!/bin/sh -xe
# usage get $1 xdevname from xinput
# ${HOME}/howto/x/amphetimouse_xinput.sh 'CHERRY CHERRY Wireless Device'
c1=$1
#twitchyness
c2=$2 
xdev=${c1:="Kensington Kensington Expert Mouse"}
xtwitch=${c2:="0.33"}
 

xsetprp="xinput --set-prop"

xinput list-props "$xdev" | grep "Accel Custom"
# start custom accel curve
#                                                 adaptive
#                                                   flat 
#                                                     custom
$xsetprp "$xdev" "libinput Accel Profile Enabled" 0 0 1

# step at 0.5 .. is twitchy 1.0 is sluggish
$xsetprp "$xdev" "libinput Accel Custom Motion Step" $xtwitch

# curve 
$xsetprp "$xdev" "libinput Accel Custom Motion Points" 0.0 0.1 0.3 1.3 6


# curve 
$xsetprp "$xdev" "libinput Accel Custom Scroll Step" 0.1
$xsetprp "$xdev" "libinput Accel Custom Scroll Points" 0.0 0.1 0.3 1.3 6

echo speed!
xinput list-props "$xdev" 
