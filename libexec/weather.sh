#!/bin/sh -ex
latlon=`cat ${HOME}/tmp/whereami.latlon`
#EEurl='https://forecast.weather.gov/meteograms/Plotter.php?lat=32.9&lon=-71.7&wfo=LWX&zcode=MDZ013&gset=18&gdiff=3&unit=0&tinfo=EY5&ahour=0&pcmd=11101111110000000000000000000000000000000000000000000000000&lg=en&indu=1!1!1!&dd=&bw=&hrspan=48&pqpfhr=6&psnwhr=6'
url="https://forecast.weather.gov/meteograms/Plotter.php?${latlon}&wfo=LWX&zcode=MDZ013&gset=18&gdiff=3&unit=0&tinfo=EY5&ahour=0&pcmd=11101111110000000000000000000000000000000000000000000000000&lg=en&indu=1!1!1!&dd=&bw=&hrspan=48&pqpfhr=6&psnwhr=6"

tf=`mktemp /tmp/weather.XXX`
curl $url > $tf
xv $tf
rm $tf

