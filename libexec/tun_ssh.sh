#!/bin/sh
#
# run me like:
# @reboot screen -S tunssh -d -m "${HOME}/bin/tun_ssh.sh"
# tun_ssh.sh ssh://nob@targdis.net:22  22
set -x
set -e 
mypid=$$
hname=`hostname`
#picking a stable port number to forward
unum=`hostname | od | sum | cut -f1 -d" "`
tunneltarget=${1}
local_sshport=${2:-"22"}

#test the local connection
ssh ssh://localhost:$local_sshport true

#dont step on my own gastropod

pidfile=`echo $1-$2 | tr -c "[:alpha:][:digit:]" "_"`
pidfile=${HOME}/tmp/${pidfile}.pid


cleanuppid() {
  echo foom:  cleanup $pifile
  rm $pidfile
  exit
}

trap  cleanuppid SIGKILL SIGINT

if [ -f $pidfile ]
then
  echo am I running ont top of my
  echo $pidfile 
  cat $pidfile
  exit
fi
echo $mypid > ${pidfile}

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

