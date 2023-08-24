#!/bin/sh -e 
ifile=$1

while IFS= read -r  line
do
	printf "$line :\n"
	git_branchesjson.sh $line | jq  -r '.[].name'
done < ${ifile}



