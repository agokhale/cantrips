setenv D /z/aeria
mkdir -p $D 
cd /usr/src
make buildworld 
make installworld DESTDIR=$D 
make distribution DESTDIR=$D 
mount -t devfs devfs $D/dev 
