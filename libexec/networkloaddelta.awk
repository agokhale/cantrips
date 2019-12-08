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
	earliestwhen = 2^63;
	latestwhen = 0;
	if ( iface == "" ) { print ( "need -v iface"); exit (-1); }
}

$0 ~ iface  {  
when[iface] = $1; 
if (when[iface] < earliestwhen ) { earliestwhen = when[iface]}; 
if (when[iface] > latestwhen ) { latestwhen = when[iface]}; 
rxb[iface] = $3;
txb[iface] = $4;

if ( lastwhen[iface]  && ( when[iface] - lastwhen[iface] > 0) ) {
	rxbps[iface] = bpscal(lastwhen[iface] , when[iface], lastrxb[iface], rxb[iface]);
	txbps[iface] =  bpscal( lastwhen[iface], when[iface], lasttxb[iface], txb[iface]) ;
	deltawhen = when[iface]-earliestwhen;
	if ( select=="tx" )
		printf ( "%i\t%f\n" , deltawhen, txbps[iface]); 
	else if (select=="rx")
		printf ( "%i\t%f\n" , deltawhen,  rxbps[iface] ); 
	else 
		printf ( "%i\t%f\t%f\n" , deltawhen,  rxbps[iface] , txbps[iface]); 
	}
lastwhen[iface] = when[iface];
lastrxb[iface] = rxb[iface];
lasttxb[iface] = txb[iface]; 
}

