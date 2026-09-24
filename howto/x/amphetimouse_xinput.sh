#!/bin/sh -xe

xdev="Kensington Kensington Expert Mouse"
 

xsetprp="xinput --set-prop"

xinput list-props "$xdev" | grep "Accel Custom"
# start custom accel curve
#                                                 adaptive
#                                                   flat 
#                                                     custom
$xsetprp "$xdev" "libinput Accel Profile Enabled" 0 0 1

# step at 0.5 .. is twitchy 1.0 is sluggish
$xsetprp "$xdev" "libinput Accel Custom Motion Step" 0.33

# curve 
$xsetprp "$xdev" "libinput Accel Custom Motion Points" 0.0 0.1 0.3 1.3 6

echo speed!
xinput list-props "$xdev" | grep "Accel Custom"
