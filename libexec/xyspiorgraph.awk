#!/usr/bin/awk -f

BEGIN {
w=30.1
d=0.0122
srand()
for ( i=-w; i < w; i += d) {
	y1 =  sin(i);
	y2 =  cos(i);
	printf ( " %f	%f	%f\n", cos(i*( rand()/20) )-log(14.1*i), y1, y2 );
 }
}

