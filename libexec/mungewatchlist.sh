#!/bin/sh -x 
cat $1 | awk '// { FS=","; if ($6> 0.01) {printf ("%3.3f\t%4.2f\t%4.2f\t%s\n",  $6/$5,  $6 , $5, $1); }}' | sort -rn | uniq
