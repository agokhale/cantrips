#!/usr/bin/nawk -f
BEGIN { 
#	print ( "hellowworld" ); 
	}

/ses/ { 
	#print ( $1 " found");
	gsub ( /:/,  "", $1)
	lses = $1
	}

/Enclosure Name/ { 
	FS=":"; 
	lencname=$2; 
	#print ("  encname: " lencname ); 
	}

#        Element 4, Type: Array Device Slot
/Element/ {
	FS=" "
	lelt=$2; 
	gsub ( /,/,"", lelt); # dump the ,
	ltype=$4 $5 $6
	}

#                Status: OK (0x01 0x00 0x00 0x00
/Status/ {

	FS=":"
	split ( $2, splitout, " " ); 
	lstatus=splitout[1]
	}
	
#                Description: Disk #0F
/Description/ { 
	FS=":"
	ldesc = $2
 	}

	
#                Device Names: da15,pass16
/Device Names/ {
	FS=":"
	split ( $2, splitout, "," ); 
	if ( match( splitout[1], "da") > 0 )  {
		print (" slot: " ldesc " status: " lstatus  " ses: " lses " disk: " splitout[1]);
	} else {
		print (" slot: " ldesc " status: " lstatus  " ses: " lses " empty: " $2);
		}
	
	}
	
	

END  { 
#print ( "byeo " NR " records found " ); 
}
