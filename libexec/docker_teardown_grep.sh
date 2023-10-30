#!/bin/sh 
set -x 
set -e

#report containers
pids=`docker ps --all | grep ${1}`
read ok
#get pids
pids=`docker ps --all | grep ${1} | cut -f1 -w`
read ok

docker stop $pids 
docker rm $pids 



