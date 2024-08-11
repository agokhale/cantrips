#!/bin/sh
#!/bin/sh -xe

#output looks like: lat=33.16&lon=-71.23213.

wherefile="${HOME}/tmp/whereami.latlon"
curl \
	-s "https://www.googleapis.com/geolocation/v1/geolocate?key=${GOOGLE_CREDENTIALS}" \
	-d"{considerIp:true}" -H "Content-Type: application/json" \
	|  \
	jq --join-output ' .location | (   "lat="+(.lat | tostring)   ,  "&lon="+(.lng | tostring)   )' \
	> $wherefile

cat $wherefile


