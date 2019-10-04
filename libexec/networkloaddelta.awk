#!/usr/bin/awk -f
#calculate delta's for xyplot's benefit 
#tail -50 ~/tmp/netload.history | networkloaddelta.awk | xyplot.awk
# -v select=tx or
# -v select=rx

function bpscal ( t2 ,t1 , bytes2, bytes1 ) {
	return (( bytes2 - bytes1 )  / ( t2 - t1)/1000000);
}

// {  
when = $1; 
rxb = $2;
txb = $3;

if ( lastwhen  && ( when - lastwhen > 0) ) {
	rxbps = bpscal(lastwhen , when, lastrxb, rxb);
	txbps =  bpscal( lastwhen, when, lasttxb, txb) ;
	if ( select=="tx" )
		printf ( "%i\t%f\n" , when,  txbps); 
	else if (select="rx")
		printf ( "%i\t%f\n" , when,  rxbps ); 
	else 
		printf ( "%i\t%f\t%f\n" , when,  rxbps , txbps); 
	}
lastwhen = when;
lastrxb = rxb;
lasttxb = txb; 
}

