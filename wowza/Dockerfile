ARG WOWZA_VERSION=4.7.8
FROM wowzamedia/wowza-streaming-engine-linux:${WOWZA_VERSION}

RUN apt-get update
RUN apt-get -y install ant

ADD ./custom_entrypoint.sh /sbin/custom_entrypoint.sh