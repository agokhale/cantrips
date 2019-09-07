#!/usr/bin/awk -f
#
# takes a  a space deli mited tpule and acsigraphs it:
# sinexx.awk | xyplot.awk  [-v rows=34 -v cols=15]
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
	bignum=100000000;
	xmax=-bignum;
	xmin=bignum;
	ymax=-bignum;
	ymin=bignum;
	xsum=0;
	ysum=0;

	points=0;
	if ( ! cols )
		"tput col"   | getline cols;
	if ( ! rows )
		"tput lines" | getline rows;


	cols -= 3
	rows -= 6;
}

/[[:digit:][:space:].].*/ {
	 x = $1;
	 y = $2;
	 xsum+= x;
	 ysum+= y;
	 if (xmax < x ) { xmax = x; }
	 if (xmin > x ) { xmin = x; }
	 if (ymax < y ) { ymax = y; }
	 if (ymin > y ) { ymin = y; }
	 points ++;
	 clust[points]=sprintf("%f\t%f", x,y);
}


function scale ( inmax, inmin, scalemax, scalemin, in_val) {
	scale_factor =( ( scalemax - scalemin ) / ( inmax - inmin )) ;
	out_val = scalemin + (  (in_val - inmin ) * scale_factor ) ; 
	return (int( out_val)) ;
}

function dsymbol ( in_d) {
	outval = " ";
	if ( in_d > 64 ) {
		outval = "@";
	} else if ( in_d > 32) { 
		outval = "X";
	} else if ( in_d > 16) { 
		outval = "O";
	} else if ( in_d > 8) { 
		outval = "*";
	} else if ( in_d > 4) { 
		outval = "=";
	} else if ( in_d > 2) { 
		outval = "+";
	} else if ( in_d > 0) { 
		outval = "-";
	}
	return ( outval);
}

END {

	xmean = xsum / points;
	ymean = ysum / points;
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
	xvmean =  scale(xmax, xmin, cols, 0 , xmean);
	yvmean =  scale(ymax, ymin, rows, 0 , ymean);

	print ("ymax", ymax);
	for ( rowcursor= 0; rowcursor<=rows; rowcursor++) {
		for ( cc=0; cc <= cols; cc++ ) {
			sym = dsymbol(  raster[ cc, rows - rowcursor] );
			printf ( "%c" , sym );
		}
		#end of row 
		if (  yvmean == rows - rowcursor ) {
			printf ("=\n");
		} else 
		{ printf( "|\n"); }
	}
	for ( c = 0; c <= (cols );  c++) {
		if ( xvmean ==  c ) {
			printf ("|");
		} else {
			printf ("-");
		}
	}
	printf ("\n");
	printf ( "ymin %f ", ymin)
	printf ( "xmin %f ", xmin);
	printf ( "count %i xmax %i ",points,  xmax);
	printf ( "xmean %f ymean  %f\n",xmean,  ymean);

}
