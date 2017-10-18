#!/usr/bin/nawk -f

($1 ~ /pool:/) {
	lpool = $2;
	#print ("gotpool: " $2);
	}

/ONLINE/ {
	if ( match ( $1, "gptid") || match ($1, "[a]*da[0-9]") || match ($1, "diskid")   )  {
		print ( "disk: " $1  " state: "  $2  " vdev: " lvdv " pool: " lpool); 
	} else if (match ($1, "mirror") || match ($1, "log") || match ( $1, "cache") || match ($1, "raidz") ){
		lvdv = $1
		#print ( "mrirrorvdev: " lvdv ); 
	} else {
	#print ( "not ??: " $1 ); 
	}
	
}
