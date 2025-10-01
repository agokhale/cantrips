#!/bin/sh -xe

srcpat=$1
destpat=$2

if [ 2 -ne  $# ]; then   
	echo $# args: $*
	echo usage: bulkrename srcpatern dstpatern
	exit 3
fi 


echo renaming $1 to $2

ls | grep "${srcpat}" | awk  -v spat="${srcpat}"  -v dpat="${dstpat}"        \
	'// {o = $0; r = gsub (spat,  dpat, $0); printf( "mv \"%s\" \t\t\t \"%s\"\n ", o, $0 ) }   '



