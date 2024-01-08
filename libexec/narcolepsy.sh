#!/bin/sh -xe
sleep "$1"
echo "feeling tired" | wall 
sleep 60
sudo  poweroff
