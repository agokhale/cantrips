#!/usr/bin/awk -f 
#
# takes a  a space delimited n-tupule and acsigraphs it:
# input format: x	y1	y2 ....
# sinexx.awk | xyplot.awk  [-v rows=34 -v cols=15  -v f[xy]=[log,sin,cos,sqrt,exp] -v verbose=1 -vnooverlay=1
# hi res torture 
# sin.awk -v frequency=100000 -v timesteps=10000 -v precision=0.000000001 -v amplitude=0.00000001 | xyplot.awk 

#ymin 0xmin -30---------------------------------------------------------count 27364 xmax 30#


BEGIN {
	# epsilon_zoom represents small windows of data which we should zoom into 
	epsilon_zoom=0.009;
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
	rows -= 3;
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
	if (verbose > 8 ) { printf ("numberonly: in: %s", i); }

	gsub (/[^.[:digit:]\-+Ee]/,"",i); 

	if ( col_nm == "x" &&  fx != ""  ) {
		i = fltr( fx  , i );  
	} else if ( col_nm == "y" &&  fy != ""  ) {
		i = fltr( fy , i );  
	}
	if (verbose > 8 ) { printf (" out %s\n", i); }
	return ( i );
}
function rangeck( i ) {
	if ( i > bignum || i < -bignum || i == nan ) {
		if ( num == 0 ) return 0;
		if ( verbose ) printf ("row: %i range error %s ($0)  %i %i %i\n", NR,i , i > bignum , i < -bignum , i == nan); 
		return 1
	}
	return  0
}

/#.*/ {
#toss whitespace
}

/[[:digit:][:space:].-e].*/ {
	if (verbose > 5) 
		printf ("naked line %s\n", $0);

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
		clust[points]=sprintf("%e\t%e\y%i", x,y,yfield);
		if (verbose > 2 ) print (points,  clust[points]);
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
# Density function providea a mapping from a static range of occurances in
# in a graph pile-up where many points are being over striked
# this is the basis for a poor 3rd dimnesion for a 2d histogram
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
function fmtstringfor (use_scinote ) {
	if ( use_scinote ) {
		fstring = "{%s:%.4e}";
	}else {
		fstring ="{%s:%2.2f}";
	}
	return (fstring); 
}

function overlay( fb, instr, ro, co, reverse ) {
	if ( nooverlay ) { return 0;}
	for ( i=1; i <= length(instr); i++ ) {
		if ( reverse == "reverse") 
			left_bump=length (instr);
		else left_bump =0; 
		fb [int(ro),int(i+co-left_bump-1)] = substr(instr, i,1);  
	}
}
END {
	if (points == 0 ) { exit (-4);}
	if ( xmax < epsilon_zoom  && xmax > -epsilon_zoom ) {
		if ( xmin > -epsilon_zoom  && xmin > -epsilon_zoom ) {
			#be better when inputs are small
			xd_is_small=1;
		}
	}
	if ( ymax < epsilon_zoom  && ymax > -epsilon_zoom ) {
		if ( ymin > -epsilon_zoom  && ymin > -epsilon_zoom ) {
			#be better when inputs are small
			yd_is_small=1;
		}
	}
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

	for ( pointcursor =1; pointcursor <= points; pointcursor ++) {
		split ( clust[pointcursor], pt);
		xv =  scale(xmax, xmin, cols, 0 , pt[1]);
		yv =  scale(ymax, ymin, rows, 0 , pt[2]);
		if (verbose > 3) printf ( "scaled %5e,%5e   to  %i ,  %i\n",pt[1], pt[2], xv, yv );
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
			if (verbose>2 && sym != " " ) printf ( "symbol %e %e %c \n" ,cc, rows - rowcursor, sym );
		}
		#end of row 
		if (  yvmean == rows - rowcursor && !nooverlay ) {
			#printf ("=\n");
			fbuf[ rowcursor, cols]= "=";
		} else if ( ! nooverlay) { 
			#printf( "|\n"); 
			fbuf[  rowcursor,cols]= "|";
		}
	}
	# bottom scale with pips 
	for ( c = 0; c <= (cols) && ( !nooverlay) ;  c++) {
		if ( xvmean ==  c ) {
			#printf ("|");
			fbuf[ rows,c]= "|";
		} else {
			#printf ("-");
			if  (fbuf[ rows,c] == " " )
				#allow data to poke through the bars/pips, except for the ^^ average
				fbuf[ rows,c]= "-";
		}
	}
	if ( verbose ) { 
		printf ("\n"); 
		printf ( "ymin %e ", ymin);
		printf ( "xmin %e ", xmin); 
		printf ( "count %i xmax %e ",points,  xmax); 
		printf ( "xmean %e ymean  %e\n",xmean,  ymean);
	}

	ymax_s = sprintf (fmtstringfor(yd_is_small),"ymx", ymax);
	overlay( fbuf, ymax_s , 0,0);
	ymin_s = sprintf (fmtstringfor(yd_is_small), "ymin", ymin);
	overlay( fbuf, ymin_s , rows, 0);
	yd_s = sprintf (fmtstringfor(yd_is_small),"yd",ymax-ymin);
	overlay( fbuf, yd_s , int(rows/2), 0, 0 ); 

	count_s=sprintf ("{ct:%i}",points);
	overlay( fbuf, count_s , rows, cols, "reverse"); 

	#xmean_s = sprintf ("{xme:%f}",xmean);
	xmean_s = sprintf (fmtstringfor(xd_is_small),"xme",xmean );
	if ((xmax - xmin) > 0 )
		overlay( fbuf, xmean_s , rows, int(cols*((xmean-xmin) / (xmax-xmin) )) , "reverse"); 

	ymean_s = sprintf (fmtstringfor(yd_is_small), "yme", ymean);
	if ((ymax - ymin) > 0 ){
		ymloc =  ( rows - int(  rows *( (ymean-ymin) / (ymax - ymin) ))  );
		#push this out of the margin if it will hit the label
		if ( ymloc > rows-2) ymloc-=1; 
		overlay( fbuf,ymean_s ,  ymloc  , cols, "reverse"); 
	}

	xmin_s = sprintf (fmtstringfor(xd_is_small),"xmn",xmin );
	overlay( fbuf, xmin_s , rows-1, 0, 0 ); 

	xmax_s = sprintf (fmtstringfor(xd_is_small),"xmx",xmax );
	overlay( fbuf, xmax_s , rows-1, cols, "reverse" ); 
	xd_s = sprintf (fmtstringfor(xd_is_small),"xd", xmax-xmin);
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
