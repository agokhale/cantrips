#!/usr/bin/awk -f 
# netstat -i -b |  networkloadhistorypoint.awk  -v iface=lo0 >> net.history
# ooutput:iface	    epocktime		rxbytes	txbytes

/Link#/ { 
	iface= $1;
	rxbytes= $8; 
	txbytes = $11;
	"date +'%s'"| getline epochtime ; 
 	printf ("%i\t%s\t%i\t%i\n",epochtime,iface,rxbytes,txbytes);
}
