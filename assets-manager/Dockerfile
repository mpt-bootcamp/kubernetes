# Using a base image 
FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y uuid-runtime \
  && apt-get install -y unzip \
  && apt-get install -y wget \
  && apt-get install -y openjdk-8-jdk-headless \ 
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /apps/assets-manager

RUN wget https://github.com/mpt-bootcamp/assets-manager/releases/download/v1.0.0/assets-manager-1.0.0.zip \
  && unzip assets-manager-1.0.0.zip \
  && chmod 755 ./bin/startup.sh


EXPOSE 9000

# CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
CMD /apps/assets-manager/bin/startup.sh

