#!/usr/bin/awk -f 

# netstat -i -b |  networkloadhistorypoint.awk  >> net.history
# ooutput:    epocktime		rxbytes	txbytes

// { rxbytes+= $8; txbytes += $11}  

END{ 
	"date +'%s'"| getline epochtime ; 
 	printf ("%i\t%i\t%i\n",epochtime,rxbytes,txbytes);
}
