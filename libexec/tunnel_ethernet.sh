#!/bin/sh 
### BEGIN INIT INFO
# Provides:          
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description:  ash ssh tunnel broker
# Description:       
#                    tunnel home
### END INIT INFO

lhost="rien"
ltapdev=248
lip="192.168.239.248" #by convention whatever works on the remote bridge/or DHCP
lipmask="255.255.255.0" # destmask for the route
ltestip="192.168.239.1"  # A host to check for before trying to bounce the bridge. 
rtapdev=248 # remote side tapdev to create
rhost="delerium.dyn.aeria.net"
pidfile="/var/run/tapneling.$ltapdev.pid"

t_watchdog()
    {
    ping -c 1 $ltestip
    if [ "$?" = "1" ]; then 
        logger "watchdog resetting tunnel ethernet"
        t_restart
    fi
    }
t_restart()
	{
	t_stop
	t_start
	}
t_start() 
	{
	logger "tapneling started for $lip $lhost:tap$ltapdev => $rhost:$rtapdev"
	ifconfig tap$ldapdev down  > /dev/null 2>%1 
	ssh -N -n  -f  -o"Tunnel=ethernet" -w $ltapdev:$rtapdev $rhost 
	##record id of bg ssh jobs
	echo $! > $pidfile

	##_______________________wait to see that the tap device shows up
	while [ `ifconfig -a | grep "tap$ltapdev" | wc -l` != '1' ]   
		do
			#ifconfig -a | grep "tap$ltapdev" 
			sleep 1
			echo -n .
		done

	ifconfig tap$ltapdev $lip $lipmask > /dev/null 2>%1
	ifconfig tap$ltapdev up > /dev/null 2>%1
	}
t_stop()
	{
	kill  `cat $pidfile`
	rm  -f $pidfile
	ifconfig tap$ldapdev down  > /dev/null 2>%1 
	logger "tapeling down for $ltapdev"
	}

case "$1" in
	start)
		t_start
		;;
	restart)
		t_stop
		t_start
		;;
	stop)
		t_stop
		;;
	status)
		ps auxw | grep "ssh -o.Tunnel.eth" | grep -v grep
        ping -c 2 $ltestip
        echo -n "pid:"; cat $pidfile
		;;
	watchdog)
        t_watchdog
		;;
	*)
		echo "usage stop|start|status"
		;;
esac
exit 0;
