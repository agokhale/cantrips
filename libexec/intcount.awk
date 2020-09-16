#!/usr/bin/awk -f

#print things that scan as integers
#usage: ./intcount.awk < sillicon_subc | sort | uniq -c | sort -rn 

// {  
	if ( dbg) print $0;
	for ( fn=1; fn < NF; fn++ ) {
		printf ( "%i\n",  $fn);
	}
}
	

