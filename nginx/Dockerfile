# Using a base image 
FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y uuid-runtime \
  && apt-get install -y nginx \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD index.html /var/www/html/
ADD images /var/www/html/images

WORKDIR /apps/nginx

ADD bin/startup.sh /apps/nginx/bin/startup.sh
RUN chmod 755 /apps/nginx/bin/startup.sh


EXPOSE 80

# CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
CMD /apps/nginx/bin/startup.sh

