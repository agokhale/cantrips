#!/bin/sh

now=`date +"%s"`

echo "generating selfsigned keys for ${now}"
openssl genrsa -des3 -out ${now}_passworded_server.key 1024
echo "#strip passwd"
openssl rsa -in ${now}_passworded_server.key  -out ${now}_server.key
echo "#pmake csr"
openssl req -new -key ${now}_server.key -out ${now}_server.csr
#selfsignedcert
echo "#make selfsignedcrt for 10 years"
openssl x509 -req -days 3650 \
	-in ${now}_server.csr -signkey ${now}_server.key -out ${now}_server.crt


