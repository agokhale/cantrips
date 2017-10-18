#!/usr/bin/nawk -f
#turn zpool status in to useful output

#  pool: zdb-test
($1 ~ /pool:/) {
	lpool = $2;
	#print ("gotpool: " $2);
	}

/ONLINE/ {
	#bug: needs an entry for every vdev type
	if ( match ( $1, "gptid") || match ($1, "[a]*da[0-9]") || match ($1, "diskid")   )  {
	#            gptid/13377042-b351-11e7-8040-0007432ba650  ONLINE       0     0     0
	# get device ^^^^^^^^                      and      status^^^^
		print ( "disk: " $1  " state: "  $2  " vdev: " lvdv " pool: " lpool); 
	} else if (match ($1, "mirror") || match ($1, "log") || match ( $1, "cache") || match ($1, "raidz") ){
	#          mirror-0                                      ONLINE       0     0     0
	# pick  vdev ^^^^^
		lvdv = $1
		#print ( "mrirrorvdev: " lvdv ); 
	} else {
	#print ( "not ??: " $1 ); 
	}
	
}

#
#
#  pool: zdb-test
# state: ONLINE
#  scan: none requested
#config:
#
#        NAME                                            STATE     READ WRITE CKSUM
#        zdb-test                                        ONLINE       0     0     0
#          mirror-0                                      ONLINE       0     0     0
#            gptid/13377042-b351-11e7-8040-0007432ba650  ONLINE       0     0     0
#            gptid/13e82d5b-b351-11e7-8040-0007432ba650  ONLINE       0     0     0
#
#errors: No known data errors
#
