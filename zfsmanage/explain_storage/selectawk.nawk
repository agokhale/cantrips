#!/usr/bin/awk -f
// { 
	if (match( $0, grepkill )> 0 ){
		mstr =select"[a-zA-Z0-9/]*"
		match ($0, mstr); 
		print (substr($0,RSTART+length(select), RLENGTH-length(select)));
		}
	}

