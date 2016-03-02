FROM alpine:latest
MAINTAINER Denis Chekirda <dchekirda@gmail.com>

RUN apk update && apk upgrade && \
  apk add ruby-json ruby-irb ruby-nokogiri ruby-thread_safe ruby-tzinfo bash && \
  apk add build-base ruby-dev && \
  gem install --no-document fluentd && \
  gem install fluent-plugin-elasticsearch --no-document &&\
  gem install fluent-plugin-xml-parser --no-document &&\
  gem install fluent-plugin-tail-multiline-ex --no-document &&\
  apk del build-base ruby-dev && \
  rm -rf /root/.gem

COPY config/fluentd.conf /etc/fluent/fluent.conf
EXPOSE 24224

CMD ["/usr/bin/fluentd"]
