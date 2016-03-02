FROM alpine
MAINTAINER Denis Chekirda <dchekirda@gmail.com>

ENV JAVA_VERSION 7.79.2.5.6-r0
ENV ELASTICSEARCH_VERSION 1.4.4

RUN apk update && apk upgrade
RUN apk add openjdk7-jre-base=$JAVA_VERSION
RUN apk add openssl ca-certificates curl

RUN \
  mkdir -p /opt && \
  cd /tmp && \
  curl https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.tar.gz > elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  tar -xzf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  rm -rf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  mv elasticsearch-$ELASTICSEARCH_VERSION /opt/elasticsearch

ADD ./elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml

VOLUME ["/var/lib/elasticsearch"]

EXPOSE 9200
EXPOSE 9300

CMD ["/opt/elasticsearch/bin/elasticsearch"]
