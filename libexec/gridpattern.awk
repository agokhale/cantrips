#!/usr/bin/awk -f
# make a grid patter
# -vxspace -vyspace -vxcount -ycount


BEGIN {
if (!xspace  ) { print ("# -vxspace -vyspace -vxcount -ycount")} ; 

for (i=0; i < ycount; i++ ) {
	for ( j =0; j < xcount ; j++ ) { printf ("%f %f \n", j*xspace, i*yspace );}
	}
exit 0;
}
