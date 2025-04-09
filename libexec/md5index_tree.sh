#!/bin/sh -x
usage(){
	echo "md5index_path"
}


#find position depentant  so print0 is last
# -x don't cross fs mounts
# -s lex ordering
find -x -s .   -print0 \
	| xargs -0 -n1 -I%   \
		md5sum % >> index.md5 

exit

