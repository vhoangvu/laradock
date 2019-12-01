ARG WOWZA_VERSION=4.7.8
FROM wowzamedia/wowza-streaming-engine-linux:${WOWZA_VERSION}

RUN apt-get update
RUN apt-get -y install ant
RUN apt-get -y install xmlstarlet
RUN apt-get -y install openjdk-11-jdk

ADD ./custom_entrypoint.sh /sbin/custom_entrypoint.sh