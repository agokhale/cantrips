#poudriere jail -c -j 12c -v 12.0-CURRENT
#poudriere jail -c -j 10stab -v 10.4-STABLE
#poudriere jail -c -j 11rel -v 11.1-RELEASE -a amd64 -m ftp
#one for the default
#poudriere ports -c 
#poudriere ports -c -p mutate
#poudriere options  -j 12c -f minimal_poudriere_packlist -z minset  -p mutate
#poudriere bulk  -j 12c -f minimal_poudriere_packlist -z minset -p mutate 
#git clone https://github.com/agokhale/freebsd-port-net-viamillipede /usr/local/poudriere/ports/mutate/net/viamillipede

# poudriere testport -j 10-3rel -p mutate -z troubleset net/viamillipede
