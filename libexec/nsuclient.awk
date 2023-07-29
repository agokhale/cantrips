#!/usr/bin/awk -f
# nsupdate.awk -vip=1.2.3.4 -vhost=frob.nsiggle.com -vkey=toomany.sekr  -vserver=ns1.nsiggle.com

BEGIN {
utxt = sprintf( " server %s \
update delete %s A \
update add %s  300 IN A %s \
send \
",server,  host,  host,ip); 




print (utxt);


}
