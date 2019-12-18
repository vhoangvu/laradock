#!/bin/bash

if [ ! -f /etc/nginx/ssl/default.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/default.key" 2048
    openssl req -new -key "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.csr" -subj "/CN=default/O=default/C=UK"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/default.csr" -signkey "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.crt"
fi

if [ ! -f /etc/nginx/ssl/directory.test.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/directory.test.key" 2048
    openssl req -new -key "/etc/nginx/ssl/directory.test.key" -out "/etc/nginx/ssl/directory.test.csr" -subj "/CN=directory.test/O=directory.test/C=US"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/directory.test.csr" -signkey "/etc/nginx/ssl/directory.test.key" -out "/etc/nginx/ssl/directory.test.crt"
fi

if [ ! -f /etc/nginx/ssl/coochee.test.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/coochee.test.key" 2048
    openssl req -new -key "/etc/nginx/ssl/coochee.test.key" -out "/etc/nginx/ssl/coochee.test.csr" -subj "/CN=coochee.test/O=coochee.test/C=US"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/coochee.test.csr" -signkey "/etc/nginx/ssl/coochee.test.key" -out "/etc/nginx/ssl/coochee.test.crt"
fi

if [ ! -f /etc/nginx/ssl/deardomina.test.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/deardomina.test.key" 2048
    openssl req -new -key "/etc/nginx/ssl/deardomina.test.key" -out "/etc/nginx/ssl/deardomina.test.csr" -subj "/CN=deardomina.test/O=deardomina.test/C=US"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/deardomina.test.csr" -signkey "/etc/nginx/ssl/deardomina.test.key" -out "/etc/nginx/ssl/deardomina.test.crt"
fi

if [ ! -f /etc/nginx/ssl/vitalitycams.test.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/vitalitycams.test.key" 2048
    openssl req -new -key "/etc/nginx/ssl/vitalitycams.test.key" -out "/etc/nginx/ssl/vitalitycams.test.csr" -subj "/CN=vitalitycams.test/O=vitalitycams.test/C=US"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/vitalitycams.test.csr" -signkey "/etc/nginx/ssl/vitalitycams.test.key" -out "/etc/nginx/ssl/vitalitycams.test.crt"
fi

if [ ! -f /etc/nginx/ssl/webcam.test.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/webcam.test.key" 2048
    openssl req -new -key "/etc/nginx/ssl/webcam.test.key" -out "/etc/nginx/ssl/webcam.test.csr" -subj "/CN=webcam.test/O=webcam.test/C=US"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/webcam.test.csr" -signkey "/etc/nginx/ssl/webcam.test.key" -out "/etc/nginx/ssl/webcam.test.crt"
fi

#this part generate keystore for wowza
# if [ ! -f /etc/nginx/ssl/directory.test-keystore.jks ]; then
	# openssl pkcs12 -export -in "/etc/nginx/ssl/directory.test.crt" -inkey "/etc/nginx/ssl/directory.test.key" -name directory.test -out "/etc/nginx/ssl/directory.test-PKCS-12.p12" -passout pass:
	# keytool -importkeystore -deststorepass 123456 -destkeystore /etc/nginx/ssl/directory.test-keystore.jks -srckeystore directory.test-PKCS-12.p12 -srcstoretype PKCS12
# fi

# Start crond in background
crond -l 2 -b

# Start nginx in foreground
nginx
