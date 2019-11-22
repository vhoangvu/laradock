#!/bin/bash

#this part generate keystore for wowza from web server ssl certificate (nginx by default) 
if [ ! -f /opt/nginx/ssl/directory.test-keystore.jks ] && [ -f /opt/nginx/ssl/directory.test.crt ]; then
	openssl pkcs12 -export -in "/opt/nginx/ssl/directory.test.crt" -inkey "/opt/nginx/ssl/directory.test.key" -name directory.test -out "/opt/nginx/ssl/directory.test-PKCS-12.p12" -passout pass:123456
	keytool -importkeystore -deststorepass 123456 -destkeystore /opt/nginx/ssl/directory.test-keystore.jks -srckeystore /opt/nginx/ssl/directory.test-PKCS-12.p12 -srcstoretype PKCS12 -srcstorepass 123456 -noprompt
fi