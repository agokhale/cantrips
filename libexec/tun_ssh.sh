#!/bin/sh
#
# run me like:
# @reboot screen -S tunssh -d -m "${HOME}/bin/tun_ssh.sh"
#

hname=`hostname`
unum=`hostname | od | sum | cut -f1 -d" "`
tunneltarget=${1:-'tunnelclient@aeria.net'}
echo $unum
choix=`dc -e "$unum 65553 % p"`
echo "going to fwd: "
echo $choix
while true; do
    now=`date +'%s'`
	ssh -v  $tunneltarget  "mkdir -p tmp/tunneldb &&\
         echo '$now	$choix	$SSH_CLIENT' >> tmp/tunneldb/\\$hname "
	ssh -v -N -R $choix:localhost:22 $tunneltarget
	sleep 600
done

