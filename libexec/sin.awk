#!/usr/bin/awk -f

#run out of precsion :
# ./sin.awk -v frequency=100000 -v timesteps=10000 -v precision=0.000000001 | xyplot.aw
#./sin.awk -v frequency=1 | xyplot.aw

BEGIN {

if (! timestart ) { timestart = 0;}
if (! precision ) { precision = 1/8000;}
if (! timesteps ) { timesteps = 8000;}
if (! frequency ) { frequency = 256;}
if (! amplitude ) { amplitude = 1;}

pi = atan2(0, -1);
for ( i=timestart; i < (timestart + timesteps); i += 1) {
	axx =  amplitude * ( sin(i*(precision*frequency*2*pi))  );
	printf ( " %9e	%9e\n", i*precision, axx); 
}




}

