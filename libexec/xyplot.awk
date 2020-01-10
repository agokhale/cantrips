#!/usr/bin/awk -f 
#
# takes a  a space delimited n-tupule and acsigraphs it:
# input format: x	y1	y2 ....
# sinexx.awk | xyplot.awk  [-v rows=34 -v cols=15  -v f[xy]=[log,sin,cos,sqrt,exp] -v verbose=1
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
	bignum=2^63;
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


function fltr(fn_name, i) {
#filer refn_name ( value)
#awk's heart yearns for eval()?
	if ( fn_name == "" ) {
 		print ("funtion error"); 
        } else if ( fn_name == "log" ) {
		a = log(i)
        } else if ( fn_name == "sin" ) {
		a = sin(i)
        } else if ( fn_name == "cos" ) {
		a = cos(i)
        } else if ( fn_name == "sqrt" ) {
		a = sqrt(i)
        } else if ( fn_name == "exp" ) {
		a = exp(i)
        } else if ( fn_name == "rand" ) {
		a = rand();
        } else if ( fn_name == "" ) {
		a = log(i)
        } else if ( fn_name == "" ) {
		a = log(i)
        } else if ( fn_name == "" ) {
		a = log(i)
        } else if ( fn_name == "" ) {
		a = log(i)
        } else if ( fn_name == "" ) {
		a = log(i)
        } else if ( fn_name == "" ) {
	}
	return (a); 
}

# invoke the filters if they are  -v fx=log
function numbersonly(col_nm, i ) {
	gsub ("[^-.[:digit:]]","",i); 
	if ( col_nm == "x" &&  fx != ""  ) {
		i = fltr( fx  , i );  
	} else if ( col_nm == "y" &&  fy != ""  ) {
		i = fltr( fy , i );  
	}
	return ( i );
}
function rangeck( i ) {
	if ( i > bignum || i < -bignum || i == nan ) {
		if ( verbose ) printf ("row: %i range error %s ($0)  %i %i %i\n", NR,i , i > bignum , i < -bignum , i == nan); 
		return 1
	}
	return  0
}

/[[:digit:][:space:].].*/ {

	x = numbersonly("x",$1);
	for ( yfield = 2; yfield <= NF ; yfield ++ ) { 
		y = numbersonly("y",$yfield);
		if (rangeck( x ) || rangeck( y)) next;
		xsum+= x;
		ysum+= y;
		if (xmax < x ) { xmax = x; }
		if (xmin > x ) { xmin = x; }
		if (ymax < y ) { ymax = y; }
		if (ymin > y ) { ymin = y; }
		points ++;
		clust[points]=sprintf("%f\t%f\y%i", x,y,yfield);
	}
}


function scale ( inmax, inmin, scalemax, scalemin, in_val) {
        if (( inmax - inmin) == 0) {
            if ( verbose ) printf("divbyzeroerror:(%s) row:%i \n", $0, NR);
            return (0);
	}
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

function overlay( fb, instr, ro, co, reverse ) {
	for ( i=1; i <= length(instr); i++ ) {
		if ( reverse == "reverse") 
			left_bump=length (instr);
		else left_bump =0; 
		fb [int(ro),int(i+co-left_bump-1)] = substr(instr, i,1);  
	}
}
END {
	if (points == 0 ) { exit (-4);}
	xmean = xsum / points;
	ymean = ysum / points;
	for ( rowcursor= 0; rowcursor<=rows; rowcursor++){
		for ( cc=0; cc <= cols; cc++ ) {
			raster_count[rowcursor, cc] =0; 
			fbuf[rowcursor, cc] =" "; 
		}
	}
# raster/fbuf layout:
# (0,0) ........    (cols,0)
# ...
# ...
# (rows,0) ......(cols,rows)

	for ( pointcursor =0; pointcursor <= points; pointcursor ++) {
		split ( clust[pointcursor], pt);
		xv =  scale(xmax, xmin, cols, 0 , pt[1]);
		yv =  scale(ymax, ymin, rows, 0 , pt[2]);
		#printf ( " %i ,  %i\n", xv, yv );
		if ( raster_count[xv,yv] > 0 ) 
			{ raster_count[xv,yv]++ }
		else 
			{ raster_count[xv,yv] =1; }
	}
	xvmean =  scale(xmax, xmin, cols, 0 , xmean);
	yvmean =  scale(ymax, ymin, rows, 0 , ymean);


	## main raster output grid
	for ( rowcursor= 0; rowcursor<=rows; rowcursor++) {
		for ( cc=0; cc <= cols; cc++ ) {
			sym = dsymbol(  raster_count[ cc, rows - rowcursor] );
			fbuf[ rowcursor, cc]= sym;
			#printf ( "%c" , sym );
		}
		#end of row 
		if (  yvmean == rows - rowcursor ) {
			#printf ("=\n");
			fbuf[ rowcursor, cols]= "=";
		} else 
		{ 
			#printf( "|\n"); 
			fbuf[  rowcursor,cols]= "|";
		}
	}
	# bottom scale with pips 
	for ( c = 0; c <= (cols);  c++) {
		if ( xvmean ==  c ) {
			#printf ("|");
			fbuf[ rows,c]= "|";
		} else {
			#printf ("-");
			fbuf[ rows,c]= "-";
		}
	}
	#printf ("\n"); printf ( "ymin %f ", ymin) printf ( "xmin %f ", xmin); printf ( "count %i xmax %i ",points,  xmax); printf ( "xmean %f ymean  %f\n",xmean,  ymean);

	ymax_s = sprintf ("{ymx:%s}", ymax);
	overlay( fbuf, ymax_s , 0,0);
	ymin_s = sprintf ("{ymin:%f}", ymin);
	overlay( fbuf, ymin_s , rows, 0);

	yd_s = sprintf ("{yd:%2.2f}",ymax-ymin);
	overlay( fbuf, yd_s , int(rows/2), 0, 0 ); 

	count_s=sprintf ("{ct:%i}",points);
	overlay( fbuf, count_s , rows, cols, "reverse"); 

	xmean_s = sprintf ("{xme:%f}",xmean);
	if ((xmax - xmin) > 0 )
		overlay( fbuf, xmean_s , rows, int(cols*((xmean-xmin) / (xmax-xmin) )) , "reverse"); 

	ymean_s = sprintf ("{yme:%f}",ymean);
	if ((ymax - ymin) > 0 ){
		ymloc =  ( rows - int(  rows *( (ymean-ymin) / (ymax - ymin) ))  );
		#push this out of the margin if it will hit the label
		if ( ymloc > rows-2) ymloc-=1; 
		overlay( fbuf,ymean_s ,  ymloc  , cols, "reverse"); 
	}

	xmin_s = sprintf ("{xmn:%2.2f}",xmin);
	overlay( fbuf, xmin_s , rows-1, 0, 0 ); 

	xmax_s = sprintf ("{xmx:%2.2f}",xmax);
	overlay( fbuf, xmax_s , rows-1, cols, "reverse" ); 
	xd_s = sprintf ("{xd:%2.2f}",xmax-xmin);
	overlay( fbuf, xd_s , rows-1, cols/2, "reverse" ); 
	
	if ( title ) 
		{tit_s = sprintf ("{t:%s}",title);
		overlay( fbuf, tit_s , 0, cols/2, "" ); 
 		}
	
		
	

	##dump the fraebuffer
	for ( rowcursor= 0; rowcursor<=rows; rowcursor++) {
		for ( cc=0; cc <= cols; cc++ ) {
			printf ( "%c", fbuf[rowcursor,cc]);
		}
		printf ( "\n"); 
	}
}
