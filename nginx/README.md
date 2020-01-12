docker build -t="dockerfile/ubuntu" github.com/dockerfile/ubuntu
docker run -it --rm dockerfile/ubuntu

Install Docker.

Download automated build from public Docker Hub Registry: docker pull dockerfile/nginx

(alternatively, you can build an image from Dockerfile: docker build -t="dockerfile/nginx" github.com/dockerfile/nginx)

Usage
docker run -d -p 80:80 dockerfile/nginx
Attach persistent/shared directories
docker run -d -p 80:80 -v <sites-enabled-dir>:/etc/nginx/conf.d -v <certs-dir>:/etc/nginx/certs -v <log-dir>:/var/log/nginx -v <html-dir>:/var/www/html dockerfile/nginx
After few seconds, open http://<host> to see the welcome page.
