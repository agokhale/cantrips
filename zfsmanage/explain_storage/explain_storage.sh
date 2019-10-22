#!/bin/sh


tmpd=`mktemp -dt explainstorage`
export tmpd=$tmpd
echo $tmpd >> /tmp/explainstorage.junk
echo $tmpd 
mkdir -p  $tmpd/tempfiles
mkdir -p $tmpd/infiles

glabel status > $tmpd/infiles/glabel.out
gmultipath status >> $tmpd/infiles/glabel.out
sesutil map > $tmpd/infiles/ses.out
zpool status > $tmpd/infiles/zpool.out

cat $tmpd/infiles/ses.out | ./normalize_ses.nawk | tee $tmpd/tempfiles/ses.normal 
cat $tmpd/infiles/zpool.out | ./normalize_pool.nawk | tee $tmpd/tempfiles/pool.normal
cat $tmpd/tempfiles/ses.normal | ./join_ses.nawk   | tee $tmpd/ses.out
cat $tmpd/tempfiles/pool.normal | ./join_pool.nawk | tee $tmpd/pool.out



ls -l $tmpd
echo $tmpd 
