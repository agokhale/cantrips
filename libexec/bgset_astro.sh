#!/bin/sh
urlv='https://www.jpl.nasa.gov/spaceimages/images/largesize/PIA21460_hires.jpg'
rnd_seed=`dd if=/dev/random count=4 bs=1 | od | cut -w -f3 | head -1 `
rez='4440x3100'
rez='4440x3100'

echo dice: $rnd_seed
selected_image=`dc -e "$rnd_seed 21460 % p "`
echo lunky: $selected_image
urlv="https://www.jpl.nasa.gov/spaceimages/images/largesize/PIA"$selected_image"_hires.jpg"

curl $urlv | \
	convert -resize $rez -level 0%,230% - - | \
		display -background black -window root  -
