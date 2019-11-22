#!/bin/bash

WMSAPP_HOME="$( readlink /usr/local/WowzaStreamingEngine )"

if [ -z $WSE_MGR_USER ]; then
	mgrUser="wowza"
else
	mgrUser=$WSE_MGR_USER
fi
if [ -z $WSE_MGR_PASS ]; then
	mgrPass="wowza"
else
	mgrPass=$WSE_MGR_PASS
fi

if [ ! -z $WSE_LIC ]; then
cat > ${WMSAPP_HOME}/conf/Server.license <<EOF
-----BEGIN LICENSE-----
${WSE_LIC}
-----END LICENSE-----
EOF
fi

echo -e "\n$mgrUser $mgrPass admin|advUser\n" >> ${WMSAPP_HOME}/conf/admin.password
echo -e "\n$mgrUser $mgrPass\n" >> ${WMSAPP_HOME}/conf/publish.password
echo -e "\n$mgrUser $mgrPass\n" >> ${WMSAPP_HOME}/conf/jmxremote.password
#echo -e "$mgrUser readwrite\n" >> ${WMSAPP_HOME}/conf/jmxremote.access

if [[ ! -z $WSE_IP_PARAM ]]; then
	#change localhost to some user defined IP
	cat "${WMSAPP_HOME}/conf/Server.xml" > serverTmp
	sed 's|\(<IpAddress>localhost</IpAddress>\)|<IpAddress>'"$WSE_IP_PARAM"'</IpAddress> <!--changed for default install. \1-->|' <serverTmp >Server.xml
	sed 's|\(<RMIServerHostName>localhost</RMIServerHostName>\)|<RMIServerHostName>'"$WSE_IP_PARAM"'</RMIServerHostName> <!--changed for default install. \1-->|' <Server.xml >serverTmp
	cat serverTmp > ${WMSAPP_HOME}/conf/Server.xml
	rm serverTmp Server.xml
	
	cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
	sed 's|\(<IpAddress>${com.wowza.wms.HostPort.IpAddress}</IpAddress>\)|<IpAddress>'"$WSE_IP_PARAM"'</IpAddress> <!--changed for default cloud install. \1-->|' <vhostTmp >${WMSAPP_HOME}/conf/VHost.xml 
	rm vhostTmp
fi

#essensus customize: fix duplicate 443 port and use existing ssl certificate
if [ ! -z $SSL_WEBRTC_DOMAIN ]; then
		#this part generate keystore for wowza from web server ssl certificate (nginx by default) 
		if [ ! -f "${WMSAPP_HOME}/essensus/ssl/keystore.jks" ] && [ -f "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_CERT}" ] && [ -f "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_KEY}" ]; then
			openssl pkcs12 -export -in "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_CERT}" -inkey "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_KEY}" -name "${SSL_WEBRTC_DOMAIN}" -out "${WMSAPP_HOME}/essensus/ssl/PKCS-12.p12" -passout pass:123456
			keytool -importkeystore -deststorepass 123456 -destkeystore ${WMSAPP_HOME}/essensus/ssl/keystore.jks -srckeystore ${WMSAPP_HOME}/essensus/ssl/PKCS-12.p12 -srcstoretype PKCS12 -srcstorepass 123456 -noprompt
		fi
fi
if [ -f "${WMSAPP_HOME}/essensus/ssl/keystore.jks" ]; then
		cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
		sed 's|\(<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/keystore.jks</KeyStorePath>\)|<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/essensus/ssl/keystore.jks</KeyStorePath> <!--changed for default install. \1-->|' <vhostTmp >VHost.xml
		sed 's|\(<KeyStorePassword>\[password\]</KeyStorePassword>\)|<KeyStorePassword>123456</KeyStorePassword> <!--changed for default install. \1-->|' <VHost.xml >vhostTmp
		sed -e '/.*<!-- 443 with SSL -->$/ {
			N; /.*<!--$/ {
				N; /.*<HostPort>$/ {
					s/.*<!--//;
				}
			}
		}' <vhostTmp > VHost.xml
		sed -e '/.*<\/HostPort>$/ {
			N; /.*-->$/ {
				s/-->//;
			}
		}' <VHost.xml > vhostTmp
		sed 's|\(<Port>1935,80,443,554</Port>\)|<Port>1935,80,554</Port> <!--changed for default install. \1-->|' <vhostTmp >VHost.xml
		cat VHost.xml > ${WMSAPP_HOME}/conf/VHost.xml
		rm vhostTmp VHost.xml
fi

# Make supervisor log files configurable
#sed 's|^logfile=.*|logfile='"${SUPERVISOR_LOG_HOME}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
