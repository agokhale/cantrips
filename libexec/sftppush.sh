#!/bin/sh
#push  a file to an sftp server via a batch file
#  ( because scp can't for some reason )


pushscript=`mktemp -t sftppushscript`

usage() {
	echo 'usage: sftppush.sh <id_file> <user>  <host> <src_file> <dst_dir>'
	exit 1
}

id_file=$1
if [ -z id_file ]; then
	usage
fi 
user=$2
if [ -z user ]; then
	usage
fi 
host=$3
if [ -z user ]; then
	usage
fi 
src_file=$4
if [ -z $src_file ]; then
	usage
fi 
dest_dir=$5
if [ -z $dest_dir ]; then
	usage
fi 


#generate the batchfile
echo "cd ${dest_dir}" >> ${pushscript}
echo "put ${src_file}" >> ${pushscript}
echo 'quit' >> ${pushscript}

sftp ${DEBUGsftp} -b ${pushscript} -i ${id_file} ${user}@${host} && mv ${pushscript} ${pushscript}.complete


