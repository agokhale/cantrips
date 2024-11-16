#!/bin/sh
#
# run me like:
# @reboot screen -S tunssh -d -m "${HOME}/bin/tun_ssh.sh"
# tun_ssh.sh ssh://nob@targdis.net:22  22
set -x
set -e 
hname=`hostname`
#picking a stable port number to forward
unum=`hostname | od | sum | cut -f1 -d" "`
tunneltarget=${1}
local_sshport=${2:-"22"}

#test the local connection
ssh ssh://localhost:$local_sshport true

#but make it low enough to TCP
fwd_port=`dc -e "$unum 65553 % p"`
echo "going to fwd: "
echo $fwd_port
while true; do
	now=`date +'%s'`
	ssh $tunneltarget  "mkdir -p tmp/tunneldb &&\
         echo '$now	$fwd_port	$SSH_CLIENT' >> tmp/tunneldb/\\$hname "
	# -N no remote command
	# -R localspec remoteport .. forwards remote_port -> localspec:portnum
	ssh -N -R $fwd_port:localhost:$local_sshport $tunneltarget
	sleep 600
done

