#!/usr/bin/awk -f
#nuselect.awk -v x=1 -v y=7
# no args to list columns with col nmumbers

function numbersonly ( i ) {
        gsub ("[^ -.[:digit:]]","",i);
        gsub ("[()]","",i);
        return ( i );
}


// { 
	$0= numbersonly($0);
	if ( x  && y ) {
		if ( y1)
			printf ( "%s	%s 	%s\n" , $x, $y, $y1);
		else 
			printf ( "%s	%s\n" , $x, $y);
		
	} else {
		for ( i=1; i<= NF; i++) {
			printf (" %d:%s\t", i,  $i);
		}
		print ("");

	}

} 
