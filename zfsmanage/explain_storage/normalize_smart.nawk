#!/usr/bin/nawk -f

function formem ( objtype, value ) {
	#printf ("\n memosize: sn: %s typ :%s val:%s \n", lsn, objtype, value);
	if ( lsn == "" ) {
		#print ("no sn, memodize", objtype, value )
		localmemo[objtype] = value
	} else {
	#	#print ("final memo for:" , lsn, objtype, value);
		finalmemo[lsn,objtype]=value
	}
}

function commitmem () {
	#print ("commit", lsn);
	for (i in localmemo) {
		#printf ("\t%s=%s\n", i, localmemo[i]); 
		formem( i, localmemo[i]);
	}
	delete localmemo
	lsn = ""
}

#xpln-start-of /dev/da8
#these tage probvided statically by parent script
($0 ~ /^xpln-start-of \/dev/) {
	ldev = $2;
	formem("dev", ldev); 
	}

#xpln-end-of /dev/da8
($0 ~ /^xpln-end-of \/dev/) {
	ldev="nomnom"
	commitmem();
}


####User Capacity:        6,001,175,126,016 bytes [6.00 TB]
## -> 6.00TB
function extractbrace ( instring ) {
	s_st = index( instring,"[");
	s_end = index( instring,"]");
	ilsize=  substr ( instring, s_st,s_end);
	gsub(  / /,"",ilsize) #lose spaces
	gsub(  /[\[\]]/,"",ilsize) #because i hate you
	return (ilsize);
	
}
####User Capacity:        6,001,175,126,016 bytes [6.00 TB]
($0 ~ /^User Capacity/  ) {
	lsize = extractbrace( $0 );
	formem("size", lsize)
	}  
###Total NVM Capacity:                 500,107,862,016 [500 GB]
/^Total NVM Capacity/  {
	lsize = extractbrace( $0 );
	formem("size", lsize)
}


($0 ~ /Product/  ) {
	lmo = $2
	formem( "model", lmo)
	}
($0 ~ /^Serial/  ) {
	lsn = $3
	formem("serial", lsn);
	pathcount[lsn] ++;
	serials[lsn]=lsn;

	paths[lsn]= sprintf ( "%s %s", paths[lsn], ldev);
	formem( "paths", sprintf( "%s %s", finalmemo[lsn,"paths"], ldev));
	}

( /^Current|^Temprature/  ) {
	formem( "temp", $4)
	}

($0 ~ /^read/  ) {
	formem("delayread", $3)
	}

($0 ~ /^write/  ) {
	formem("delaywrite", $3)
	}


END {
	for (sn in serials) {
		#printf ("sn:%s siz:%s mo:%s pathcount:%s paths:%s temp:%s dwrite:%s dread:%s  \n", sn,size[sn],model[sn],pathcount[sn], paths[sn], temp[sn], delaywrite[sn], delayread[sn] );
		printf("sn: %s\t", finalmemo[sn,"serial"]);
		printf("size: %s\t", finalmemo[sn,"size"]);
		printf("model: %s\t", finalmemo[sn,"model"]);
		printf("paths:%s\t", finalmemo[sn,"paths"]);
		if ( finalmemo[sn,"delayread"] > 0 )
			printf("dwread:%s ", finalmemo[sn,"delayread"]);
		if ( finalmemo[sn,"delaywrite"] > 0 )
			printf("dwrite:%s ", finalmemo[sn,"delaywrite"]);
		printf("temp:%s\t", finalmemo[sn,"temp"]);
		printf("\n"); 
	}
}


	
#/dev/da1
#smartctl 6.5 2016-05-07 r4318 [FreeBSD 10.3-STABLE amd64] (local build)
#Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org
# 
#=== START OF INFORMATION SECTION ===
#Vendor:               WD
#Product:              WD4001FYYG-01SL3
#Revision:             VR07
#Compliance:           SPC-4
#User Capacity:        4,000,787,030,016 bytes [4.00 TB]
#Logical block size:   512 bytes
#Rotation Rate:        7200 rpm
#Form Factor:          3.5 inches
#Logical Unit id:      0x50000c0f01e9bc90
#Serial number:        WMC1F1990828
#Device type:          disk
#Transport protocol:   SAS (SPL-3)
#Local Time is:        Mon Oct  2 09:58:11 2017 EDT
#SMART support is:     Available - device has SMART capability.
#SMART support is:     Enabled
#Temperature Warning:  Enabled
#Read Cache is:        Enabled
#Writeback Cache is:   Disabled
#
#=== START OF READ SMART DATA SECTION ===
#SMART Health Status: OK
#
#Current Drive Temperature:     22 C
#Drive Trip Temperature:        69 C
#
#Manufactured in week 19 of year 2014
#Specified cycle count over device lifetime:  1048576
#Accumulated start-stop cycles:  34
#Specified load-unload count over device lifetime:  1114112
#Accumulated load-unload cycles:  134
#Elements in grown defect list: 0
#
#Error counter log:
#           Errors Corrected by           Total   Correction     Gigabytes    Total
#               ECC          rereads/    errors   algorithm      processed    uncorrected
#           fast | delayed   rewrites  corrected  invocations   [10^9 bytes]  errors
#read:    5393500    66206     68123   5459706      66206     173233.002           0
#write:   3226925    30015     30342   3256940      30015      94112.353           0
#
