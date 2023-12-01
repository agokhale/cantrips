#!/bin/sh -e
#set -x
ip=`curl -s 'https://api.ipify.org'`
echo $ip
