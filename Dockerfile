#!/bin/sh

# Ubuntu 14.04 Builder for gcc, Java, and Node
#
# VERSION               0.0.1

FROM       ubuntu:14.04
MAINTAINER Brian Prodoehl <bprodoehl@connectify.me>

RUN apt-get -y update
RUN apt-get -y dist-upgrade

# Install build essentials
RUN apt-get -y install build-essential libasound2-dev flex bison \
                       libdbus-glib-1-dev software-properties-common \
                       subversion git g++ make 

# Install 32-bit binary build essentials
RUN apt-get -y install libc6-dev-i386 g++-multilib

# install Java 8
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN apt-get -y install oracle-java8-installer

RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y python-software-properties python nodejs

RUN npm install -g grunt-cli

# Set up remote access so it can be used as a Jenkins slave
RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd

# expose the necessary ports
EXPOSE 22

ADD startup.sh /tmp/startup.sh

# Start ssh services.
CMD ["/bin/bash", "/tmp/startup.sh"]
