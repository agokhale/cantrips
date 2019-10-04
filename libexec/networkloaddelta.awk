#!/usr/bin/awk -f
#calculate delta's for xyplot's benefit
#tail -50 ~/tmp/netload.history | networkloaddelta.awk | xyplot.awk

function bpscal ( t2 ,t1 , bytes2, bytes1 ) {
	return ( bytes2 - bytes1 )  / ( t2 - t1);
}

// {  
when = $1; 
rxb = $2;
txb = $3;

if ( lastwhen  && ( when - lastwhen > 0) ) {
	rxbps = bpscal(lastwhen , when, lastrxb, rxb);
	txbps =  bpscal( lastwhen, when, lasttxb, txb) ;
	printf ( "%i\t%f\t%f\n" , when,  rxbps , txbps); 
	}
lastwhen = when;
lastrxb = rxb;
lasttxb = txb; 
}

