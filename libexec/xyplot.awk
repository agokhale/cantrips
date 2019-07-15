#!/usr/bin/awk -f
#
# takes a  a space deli mited tpule and acsigraphs it:
# sinexx.awk | xyplot.awk                                                                                                                                                               :xpi:~/cantrips/libexec:12:56:24:248kaylee

#ymax 1.000000
#                                         .                                          |
#                                        @@@                                         |
#                                       @@ @@                                        |
#                                       @   @                                        |
#                                      @@   @@                                       |
#                                      @     @                                       |
#                                      @     @                                       |
#                                     @@     @@                                      |
#   @@@      @@@     @@@@    @@@@@    @       @    @@@@@    @@@@     @@@.     @@@    |
#@@@@ @@@@@@@  @@@@@@@  @@@@@@   @@  @@   .   @@  @@   @@@@@@  @@@@@@@  @@@@@@@ @@@@.|
#                                 @@@@         @@@@                                  |
#ymin 0xmin -30---------------------------------------------------------count 27364 xmax 30#

BEGIN {

 bignum=1000000;
 xmax=-bignum;
 xmin=bignum;
 ymax=-bignum;
 ymin=bignum;

points=0;
cols=189;
rows=50;

}

/[[:digit:][:space:].].*/ {

 x = $1;
 y = $2;
 if (xmax < x ) { xmax = x; }
 if (xmin > x ) { xmin = x; }
 if (ymax < y ) { ymax = y; }
 if (ymin > y ) { ymin = y; }
 points ++;
 clust[points]=sprintf("%f\t%f", x,y);
#print ( clust[points]);
}


function scale ( inmax, inmin, scalemax, scalemin, in_val) {
 scale_factor =( ( scalemax - scalemin ) / ( inmax - inmin )) ;
 out_val = scalemin + (  (in_val - inmin ) * scale_factor ) ; 
 return (int( out_val)) ;
}

function dsymbol ( in_d) {
	outval = " ";
	if ( in_d > 16 ) {
		outval = "@";
	} else if ( in_d > 8) { 
		outval = "*";
	} else if ( in_d > 4) { 
		outval = "0";
	} else if ( in_d > 2) { 
		outval = "o";
	} else if ( in_d > 0) { 
		outval = ".";
	}
	return ( outval);
}

END {
#print ("xmax", xmax);
#print ( "xmin", xmin); 
#print ("ymax", ymax);
#print ( "ymin", ymin); 
#print ("ymax", ymax);

for ( rowcursor= 0; rowcursor<=rows; rowcursor++){
	for ( cc=0; cc <= cols; cc++ ) {
		raster[rowcursor, cc] =0; 
	}
}

for ( pointcursor =0; pointcursor <= points; pointcursor ++) {
  split ( clust[pointcursor], pt);
  xv =  scale(xmax, xmin, cols, 0 , pt[1]);
  yv =  scale(ymax, ymin, rows, 0 , pt[2]);
  #printf ( " %i ,  %i\n", xv, yv );
  if ( raster[xv,yv] > 0 ) 
	{ raster[xv,yv]++ }
  else 
	{ raster[xv,yv] =1; }
}

print ("ymax", ymax);
for ( rowcursor= 0; rowcursor<=rows; rowcursor++) {
	for ( cc=0; cc <= cols; cc++ ) {
			sym = dsymbol(  raster[ cc, rows - rowcursor] );
			printf ( "%c" , sym );
		}
	printf( "|\n");
	}
printf ( "ymin %i", ymin)
printf ( "xmin %i", xmin);
for ( c = 11; c <= (cols - 16);  c++) {
	printf ("-");
}
printf ( "count %i xmax %i",points,  xmax);

}
