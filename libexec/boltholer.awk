#!/usr/bin/awk -f
# make a hole pattern for use with geda
# -vcount=[num] -vradius=[mm] -vdeg_offset=[degs] -vholesize=[mm] -vcenterx=mm -vcenteriy=y -vspiralize=[mm] -vovercount=[number]
#http://wiki.geda-project.org/geda:pcb-quick_reference


function radialxy (xcenter,ycenter,iradius,  idegree )  {
	pi=3.14159269;
	degtorad=(2*pi)/360;
	ret[1]=ycenter+(iradius*sin(idegree*degtorad));
	ret[0]=xcenter+(iradius*cos(idegree*degtorad));
}


BEGIN {

#printf("#boltholer.awk ");
#printf ("-vcount=%i -vradius=%i -vdeg_offset=%i  -vspiralize=%i\n" , count, radius, deg_offset, spiralize);
if (!overcount) overcount=1;
for (i=0; i < (count * overcount); i++ ) {
	degree = 360/count;
	degree *= i;
	degree += deg_offset;
	pinname=sprintf ("%i_%s",int(degree),name); 
	pinnumber=degree;
	radialxy( 0, 0, radius, degree);
	radius += spiralize;
	if( logspiralize) {radius += log ( logspiralize); }
	printf ("%f %f \n", ret[0], ret[1] );
	}
exit 0;
}
