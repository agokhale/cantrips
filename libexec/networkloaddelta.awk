#!/usr/bin/awk -f

#calculate delta's for xyplot's benefit 
#tail -50 ~/tmp/netload.history | networkloaddelta.awk | xyplot.awk
# -v select=tx or
# -v select=rx
# -v iface=bge0

function bpscal ( t2 ,t1 , bytes2, bytes1 ) {
	return (( bytes2 - bytes1 )  / ( t2 - t1)/1000000);
}
BEGIN {
	if ( iface == "" ) { print ( "need -v iface"); exit (-1); }
}

$0 ~ iface  {  
when[iface] = $1; 
rxb[iface] = $3;
txb[iface] = $4;

if ( lastwhen[iface]  && ( when[iface] - lastwhen[iface] > 0) ) {
	rxbps[iface] = bpscal(lastwhen[iface] , when[iface], lastrxb[iface], rxb[iface]);
	txbps[iface] =  bpscal( lastwhen[iface], when[iface], lasttxb[iface], txb[iface]) ;
	if ( select=="tx" )
		printf ( "%i\t%f\n" , when[iface],  txbps[iface]); 
	else if (select=="rx")
		printf ( "%i\t%f\n" , when[iface],  rxbps[iface] ); 
	else 
		printf ( "%i\t%f\t%f\n" , when[iface],  rxbps[iface] , txbps[iface]); 
	}
lastwhen[iface] = when[iface];
lastrxb[iface] = rxb[iface];
lasttxb[iface] = txb[iface]; 
}

