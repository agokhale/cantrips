#!/usr/bin/awk -f

function numbersonly ( i ) {
        gsub ("[^ -.[:digit:]]","",i);
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
		print $0
	}

} 
