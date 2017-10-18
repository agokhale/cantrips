#!/usr/bin/nawk -f

/disk:/ {
	FS=":"
	split ($2, splout, " ") 
	ldiskdev=splout[1]
	gsub (/.eli/ , "", ldiskdev);
	grepsuccess="grep " ldiskdev  " infiles/glabel.out " | getline sesline
	if ( grepsuccess )  {
		split (sesline, sessplit , " " ) 
		rdiskdev=sessplit[3]
		gsub (/p[0-9]/,"", rdiskdev);
		print ( "/dev: " rdiskdev " " $0); 
		}
	}
