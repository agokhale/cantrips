#!/bin/sh -xe

srcpat=$1
destpat=$2

if [ 2 -ne  $# ]; then   
	echo $# args: $*
	echo usage: bulkrename srcpatern dstpatern
	exit 3
fi 

echo renaming $1 to $2
srcnames=` ls  |  grep "$srcpat"`
echo srcs:
echo ${srcnames}
echo ""
# this word list  breaks spaces in files 
for i  in $srcnames; do
	echo  \#mv $i `echo ${i} | sed -e "s/${srcpat}/${destpat}/"`
done
echo ok?
read ok
for i  in $srcnames; do
	mv $i `echo $i | sed -e "s/$srcpat/$destpat/"`
done

