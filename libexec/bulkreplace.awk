#!/usr/bin/awk -f

#usage bulkreplace.awk < repl.instr  > replacer.sh
# repl.insr : 	srcpat	dstpat
#		oldpat	newpat
#		red*pat	bluepat	

BEGIN { 
	printf ("#!/bin/sh -xe\n");
	printf (" sed ");
} 

// {
	printf (" -e 's/%s/%s/' ", $1, $2);
}

END { print ("");} 
