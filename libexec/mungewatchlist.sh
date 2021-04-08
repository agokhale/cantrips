#!/bin/sh -x 
cat $1 | awk '// { FS=","; if ($6> 0.01) {printf ("%3.1f\t%s\t%s\t%s\n",  $6/$5,  $6 , $5, $1); }}' | sort -rn
