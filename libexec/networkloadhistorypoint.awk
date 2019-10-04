#!/usr/bin/awk -f 

# netstat -i -b |  networkloadhistorypoint.awk  -v iface=lo0 >> net.history
# ooutput:    epocktime		rxbytes	txbytes
BEGIN {
	print iface;
}


$0 ~ iface  { 
	rxbytes+= $8; txbytes += $11;
}  

END{ 
	"date +'%s'"| getline epochtime ; 
 	printf ("%i\t%i\t%i\n",epochtime,rxbytes,txbytes);
}
