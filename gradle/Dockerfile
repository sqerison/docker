FROM ubuntu:14.04

MAINTAINER Volodymyr Shynkar <volodymyr.shynkar@gmail.com>

RUN apt-get install software-properties-common -y && \
add-apt-repository ppa:cwchien/gradle -y  && \
add-apt-repository ppa:webupd8team/java -y && \
sudo apt-get update && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
apt-get install -y gradle oracle-java8-set-default && \
update-java-alternatives -s java-8-oracle && \
apt-get remove -y software-properties-common && \
apt-get autoremove -y

WORKDIR /opt

#ENTRYPOINT ["/usr/bin/gradle"]
