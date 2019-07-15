#!/usr/bin/awk -f
BEGIN {

w=30.1
d=0.0022
for ( i=-w; i < w; i += d) {
	printf ( " %f	%f\n", cos(i*0.3), sin(i));
 }
}

