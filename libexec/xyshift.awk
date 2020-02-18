#!/usr/bin/awk -f
# make a grid patter
# -vxshift -vyshift
// { 
	printf ( "%f %f\n",  $1+xshift , $2+yshift);
}
