#!/bin/sh -ex

for i  in `jot 14` 
do
	echo $i
	mdconfig  -d  -u $i || echo "meh"
	truncate -s 2G diskbacker.$i
	mdconfig  -t vnode  -f diskbacker.$i -u $i
done
mdconfig -l 
