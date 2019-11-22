cat "/usr/local/WowzaStreamingEngine/conf/VHost.xml" > vhostTmp
sed -i -e '/^<!--$/ {
	N; /\n<HostPort>$/ {
		s/^<!--\n//;
	}
}' vhostTmp
		
		
sed -i -e '/.*<!-- 443 with SSL -->$/ {
	N; /.*<!--$/ {
		N; /.*<HostPort>$/ {
			s/.*<!--\n//;
		}
	}
}' vhostTmp

sed -i -e '/.*<\/HostPort>$/ {
	N; /.*-->$/ {
		s/.*-->//;
	}
}' vhostTmp

sed '/<HostPort>/s/^/<!--/;/<\/HostPort>/s/$/-->/' vhostTmp > vhostTmp1
