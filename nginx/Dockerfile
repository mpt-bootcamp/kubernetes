# Using a base image 
FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y nginx \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
ADD index.html /var/www/html/
ADD images /var/www/html/images

EXPOSE 80

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
