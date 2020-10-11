#!/usr/bin/awk -f

BEGIN {

if (! timestart ) { timestart = 0;}
if (! precision ) { precision = 1/8000;}
if (! timesteps ) { timesteps = 8000;}
if (! frequency ) { frequency = 256;}
if (! amplitude ) { amplitude = 1;}

pi = atan2(0, -1);
for ( i=timestart; i < (timestart + timesteps); i += 1) {
	axx =  amplitude * ( sin(i*(precision*frequency*2*pi))  );
	printf ( " %f	%f\n", i*precision, axx); 
}




}

