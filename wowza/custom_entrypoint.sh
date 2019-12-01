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
# if [ ! -z $SSL_WEBRTC_DOMAIN ]; then
		# #this part generate keystore for wowza from web server ssl certificate (nginx by default) 
		# if [ ! -f "${WMSAPP_HOME}/essensus/ssl/keystore.jks" ] && [ -f "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_CERT}" ] && [ -f "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_KEY}" ]; then
			# openssl pkcs12 -export -in "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_CERT}" -inkey "${WMSAPP_HOME}/essensus/ssl/${SSL_WEBRTC_KEY}" -name "${SSL_WEBRTC_DOMAIN}" -out "${WMSAPP_HOME}/essensus/ssl/PKCS-12.p12" -passout pass:123456
			# keytool -importkeystore -deststorepass 123456 -destkeystore ${WMSAPP_HOME}/essensus/ssl/keystore.jks -srckeystore ${WMSAPP_HOME}/essensus/ssl/PKCS-12.p12 -srcstoretype PKCS12 -srcstorepass 123456 -noprompt
		# fi
# fi
# if [ -f "${WMSAPP_HOME}/essensus/ssl/keystore.jks" ]; then
		# cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
		# sed 's|\(<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/keystore.jks</KeyStorePath>\)|<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/essensus/ssl/keystore.jks</KeyStorePath> <!--changed for default install. \1-->|' <vhostTmp >VHost.xml
		# sed 's|\(<KeyStorePassword>\[password\]</KeyStorePassword>\)|<KeyStorePassword>123456</KeyStorePassword> <!--changed for default install. \1-->|' <VHost.xml >vhostTmp
		# sed -e '/.*<!-- 443 with SSL -->$/ {
			# N; /.*<!--$/ {
				# N; /.*<HostPort>$/ {
					# s/.*<!--//;
				# }
			# }
		# }' <vhostTmp > VHost.xml
		# sed -e '/.*<\/HostPort>$/ {
			# N; /.*-->$/ {
				# s/-->//;
			# }
		# }' <VHost.xml > vhostTmp
		# sed 's|\(<Port>1935,80,443,554</Port>\)|<Port>1935,80,554</Port> <!--changed for default install. \1-->|' <vhostTmp >VHost.xml
		# cat VHost.xml > ${WMSAPP_HOME}/conf/VHost.xml
		# rm vhostTmp VHost.xml
# fi
#essensus customize: fix duplicate 443 port and use streamlock certificate
if [ -f "${WMSAPP_HOME}/essensus/ssl/${STREAMLOCK_FILE}" ]; then
		cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
		sed 's|\(<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/keystore.jks</KeyStorePath>\)|<KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/essensus/ssl/'"$STREAMLOCK_FILE"'</KeyStorePath> <!--changed for default install. \1-->|' <vhostTmp >VHost.xml
		sed 's|\(<KeyStorePassword>\[password\]</KeyStorePassword>\)|<KeyStorePassword>'"$STREAMLOCK_PASSWORD"'</KeyStorePassword> <!--changed for default install. \1-->|' <VHost.xml >vhostTmp
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

#essensus customize: enable webrtc in VHost.xml
cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
xmlstarlet ed -L -r "/Root/VHost/HostPortList/HostPort[Port=443]" -v SSLHostPort vhostTmp
xmlstarlet ed -L -i "/Root/VHost/HostPortList/SSLHostPort/HTTPProviders/HTTPProvider[4]" -t elem -n HTTPProvider -v "" vhostTmp
xmlstarlet ed -L -s "/Root/VHost/HostPortList/SSLHostPort/HTTPProviders/HTTPProvider[4]" -t elem -n BaseClass -v "com.wowza.wms.webrtc.http.HTTPWebRTCExchangeSessionInfo" vhostTmp
xmlstarlet ed -L -s "/Root/VHost/HostPortList/SSLHostPort/HTTPProviders/HTTPProvider[4]" -t elem -n RequestFilters -v "*webrtc-session.json" vhostTmp
xmlstarlet ed -L -s "/Root/VHost/HostPortList/SSLHostPort/HTTPProviders/HTTPProvider[4]" -t elem -n AuthenticationMethod -v "none" vhostTmp
xmlstarlet ed -L -r "/Root/VHost/HostPortList/SSLHostPort" -v HostPort vhostTmp
cat vhostTmp > ${WMSAPP_HOME}/conf/VHost.xml
rm vhostTmp
#essensus customize: enable webrtc in Application.xml
cat "${WMSAPP_HOME}/conf/Application.xml" > applicationTmp
xmlstarlet ed -L -u "/Root/Application/WebRTC/EnablePublish" -v "true" applicationTmp
xmlstarlet ed -L -u "/Root/Application/WebRTC/EnablePlay" -v "true" applicationTmp
xmlstarlet ed -L -u "/Root/Application/WebRTC/EnableQuery" -v "true" applicationTmp
xmlstarlet ed -L -u "/Root/Application/WebRTC/DebugLog" -v "true" applicationTmp
xmlstarlet ed -L -s "/Root/Application/RTP/Properties" -t elem -n rtpForceH264Constraint -v "true" applicationTmp
xmlstarlet ed -L -s "/Root/Application/RTP/Properties" -t elem -n rtpForceH264ConstraintValue -v "192" applicationTmp
xmlstarlet ed -L -s "/Root/Application/RTP/Properties" -t elem -n rtpUseLowestH264Constraint -v "false" applicationTmp
xmlstarlet ed -L -s "/Root/Application/RTP/Properties" -t elem -n rtpUseHighestH264Constraint -v "true" applicationTmp
cat applicationTmp > ${WMSAPP_HOME}/conf/Application.xml
rm applicationTmp
#essensus customize: create webrtc application
if [ -d "${WMSAPP_HOME}/conf/webrtc" ]
then
	echo "webrtc configuration directory already exists.. skipping creation"
else
	mkdir "${WMSAPP_HOME}/conf/webrtc"
fi
if [ -f "${WMSAPP_HOME}/conf/webrtc/Application.xml" ] 
then
	echo "Skipping WebRTC. Already configured."
else
	echo "Installing WebRTC example package..."
	#replace external ip address in Application.xml file
	sed s/\\[external-ip-address\\]/$EXTERNAL_IP/g "${WMSAPP_HOME}/essensus/conf/webrtc/Application.xml" > ApplicationTmp.xml
	mv ApplicationTmp.xml "${WMSAPP_HOME}/conf/webrtc/Application.xml"
fi
if [ ! -d "${WMSAPP_HOME}/applications/webrtc" ]
then
	mkdir "${WMSAPP_HOME}/applications/webrtc"
fi
#essensus customize: build module
cp -a "${WMSAPP_HOME}/essensus/module/lib/." "${WMSAPP_HOME}/lib"
ant -buildfile "${WMSAPP_HOME}/essensus/module/build_server.xml" compile
#essensus customize: copy to test
cp /usr/local/WowzaStreamingEngine/conf/VHost.xml /usr/local/WowzaStreamingEngine/essensus/ssl/
cp /usr/local/WowzaStreamingEngine/conf/Application.xml /usr/local/WowzaStreamingEngine/essensus/ssl/
cp "${WMSAPP_HOME}/conf/webrtc/Application.xml" /usr/local/WowzaStreamingEngine/essensus/ssl/

# Make supervisor log files configurable
#sed 's|^logfile=.*|logfile='"${SUPERVISOR_LOG_HOME}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
