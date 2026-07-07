setenv D /zz/jail/bs
mkdir -p $D 
cd /usr/src/freebsd
make buildworld 
make installworld DESTDIR=$D 
make distribution DESTDIR=$D 
mount -t devfs devfs $D/dev 
