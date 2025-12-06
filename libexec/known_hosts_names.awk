#!/usr/bin/awk -f

# find the hosts of interest


BEGIN {
		  FS = ",[ \t]*|[ \t]+" ; # thanks manpage
		  print "localhost known_hosts_names.awk";
}


/#.*/ {
		  #toss whitespace
	next
}

/[0-9]+.[0-9]+*/ 
{ 
#print $0
}
 // { next}

END {
print ("enfd")
}

