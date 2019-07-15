#!/usr/bin/awk -f
BEGIN {

w=30.1
d=0.0122
for ( i=-w; i < w; i += d) {
	printf ( " %f	%f\n", cos(i*1.3)-log(10.1*i), sin(i));
 }
}

