#!/usr/bin/awk -f 
BGEIN { uid = "uu";}

/lease/ { ip=$2;}
/uid/ { uid=$2;}
/client-hostname/ { name= $2}
/binding state active/ { bound=1;}


/}/ {
	if ( bound==1 ){
	printf ( "%s\t%s %s \n",  ip, name,uid);
	}

	uid="";
	name="";
	bound=0;
}
