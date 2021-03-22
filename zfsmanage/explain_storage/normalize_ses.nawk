#!/usr/bin/nawk -f
#sesutil map | ./normalize_ses.awk
#        Element 12, Type: Device Slot
#                Status: OK (0x11 0x0b 0x02 0x00)
#                Device Names: da11,pass11
#                Extra status:
#                - Swapped
#                - LED=locate


function formem(sesid,  elt, elt_o_type, oval) {
	memo[sesid"%%",  elt"%%", elt_o_type"%%"] = oval;
}
/^ses/ { 
	#	print ( $1 " found");
	gsub ( /:/,  "", $1)
	lses = $1
	}
/- Swapped|- LED/ {
	formem( lses, lelt, "extrastatus", $0)
}


END {
	
	for( i in  memo) { # ses0    1       devname
		print( i, memo[i]);
		split(i,  keyfields, "%%")
		sesname = keyfields[1]
		seseltname = keyfields[2]
		otype = keyfields[3]
		distinct_ses[sesname]=1;
		#print ( "sesname",sesname); print ( "elt",seseltname); print ( "typ",otype); print ("val", memo[i]);
		distinct_elt[seseltname]=1;
		distinct_otype[otype]=1;
	}
	#print ("enclosuers");
	for (sesn in distinct_ses) {
		#print(sesn);
	}
	#print ("elements");
	for (elt in distinct_elt) {
		#printf ("%s ",elt);
	}
	#print ("\ntypes");
	for (tt in distinct_otype) {
		#print("\t",tt);
	}
	for (sesi in distinct_ses ){
		printf ("ses: %s\n" , sesi); 
		for ( elti in distinct_elt) {
			printf ("\t element:%s \t", elti);
			for ( tt in distinct_otype ) {
				memokey = sesi"%%"elti"%%"tt"%%";
				#printf( "%s: ", memokey);
				if ( memo[memokey] ) { printf ("type:%s val:%s ",  tt, memo[memokey]);}
			}
			printf ("\n");	
		}
	}
}
/Enclosure Name/ { 
	FS=":"; 
	lencname=$2; 
	formem( lses, 0, "encname", lencname)
	#print ("  encname: " lencname ); 
	}

#        Element 4, Type: Array Device Slot
/Element/ {
	FS=" "
	lelt=$2; 
	sub ( /,/, "" , lelt);
	match ($0, "Type: ")
	ltype= substr ( RSTART +6, 44);
	formem( lses, lelt, "elt_type", ltype)
	}

#                Status: OK (0x01 0x00 0x00 0x00
/Status/ {

	FS=":"
	split ( $2, splitout, " " ); 
	lstatus=splitout[1]
	formem( lses, lelt, "status", lstatus)
	}
	
#                Description: Disk #0F
/Description/ { 
	FS=":"
	ldesc = $2
	formem( lses, lelt, "desc", ldesc)
 	}

#        Element 6, Type: Device Slot
/Device Slot/ { 
	ldesc = $2
	sub ( /,/, "" , ldesc);
	formem( lses, lelt, "devslot", ldesc)
	}

	
#                Device Names: da15,pass16
#                Device Names: pass16,da15
/Device Names/ {
        #        Device Names: da3,pass3 
	diskname="noNE";
	if (match($0,"da[0-9]*")  > 1 ) {
		diskname = substr ( $0, RSTART,RLENGTH)
	}
	formem( lses, lelt, "devname", diskname)
	}

END  { 
}
#
#ses0:
#        Enclosure Name: ECStream 3U16+4R-4X6G.3 d1f8
#        Enclosure ID: 5b0bd6d0a10460bf
#        Element 0, Type: Array Device Slot
#                Status: Unsupported (0x00 0x00 0x00 0x00)
#                Description: SES Array Device
#        Element 1, Type: Array Device Slot
#                Status: OK (0x11 0x00 0x00 0x00)
#                Description: Disk #00
#                Device Names: pass13
#                Extra status:
#                - Swapped
#        Element 2, Type: Array Device Slot
#                Status: OK (0x01 0x00 0x00 0x00)
#                Description: Disk #01
#                Device Names: da1,pass2
#        Element 3, Type: Array Device Slot
#                Status: OK (0x01 0x00 0x00 0x00)
#                Description: Disk #02
#                Device Names: da0,pass1
#        Element 4, Type: Array Device Slot
#                Status: OK (0x01 0x00 0x00 0x00)
#                Description: Disk #03
#                Device Names: da2,pass3
#        Element 5, Type: Array Device Slot
#                Status: OK (0x01 0x00 0x00 0x00)
