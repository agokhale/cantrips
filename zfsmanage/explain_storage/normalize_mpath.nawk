#!/usr/bin/nawk -f
#turn zpool status in to useful output

#gmultipath status | awk '/multipath/ { mpname=$1;} /[ad][da]/ { if (match ($1,"multipath")>0) print (mpname $3); else printf( mp:%s\t kbeep?$mp[D);}'
/multipath/ { mpname=$1;} 
/[ad][da]/ { 
	if (match ($1,"multipath")>0) 
		printf( "mp:%s\t disk:%s\n", mpname, $3 );
	else 
		printf( "mp:%s\t disk:%s\n", mpname, $1 );
	}
