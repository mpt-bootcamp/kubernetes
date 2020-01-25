## Lab1 - Containerization or Dockerization

In this first lab, you will practice how to build, run and manage the lifecycle of containers.


### Exercise 1 - Installing and running a traditional application

Before we get into dockerization, let see how a traditional web application is deployed to a virtual machine.

1. From your console machine's terminal window, SSH into the worker VM to install Nginx, a web server that powers manay web applications. 

Note to replace **\<n\>** with your assigned student number.

```console
ssh -i ~/.ssh/id_rsa_ubuntu ubuntu@worker<n>.lab.mpt.local
sudo apt-get update
sudo apt-get install nginx
sudo systemctl status nginx
curl http://localhost
```

2. You can also open the default home page from the browse with this public URL:

```
http://worker<n>.missionpeaktechnologies.com
```


### Exercise 2 - Dockerizing an application

Now, let's see how to dockerize Nginx that you deployed and how to run it inside machine with Docker engine installed.

1. From your console machine's terminal window, download the Kubernetes project and use the prepare exercise files so we can save time writing them in class.

```console
cd ~/bootcamp/
git clone https://github.com/mpt-bootcamp/kubernetes.git
cd kubernetes
cat nginx/Dockerfile
```

The Dockerfile (./nginx/Dockerfile) is used to specify how you want to package the application its dependencies, and how to run the application when you instantiate and run the container image.

```
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
```

2. With the Dockerfile created, run the following commands in the console terminal to create a Nginx container image and store it in the local repository.

```console
cd ~/bootcamp/kubernetes
docker build -t mptbootcamp/nginx ./nginx
docker image ls -a
docker history mptbootcamp/nginx
```

Here you build the image with the required tag name, mptbootcamp/nginx, with the Dockerfile in the nginx directdory. The second docker command list all the images in your local repo. The last command show the build history of the container image.


3. Now let's see how containerize a Java application. Run the following commands in the console terminal to dockerize a Java application.

```console
cd ~/bootcamp/kubernetes
docker build -t mptbootcamp/assets-manager ./assets-manager
docker image ls -a
docker history mptbootcamp/assets-manager
cat assets-manager/Dockerfile
```

As you can see in the Dockerfile, there is not much different creating a Java application image than the simple Nginx application.


### Exercise 3 - Running a containerized application.


1. Run the mptbootcamp/nginx container (in the local repo, or download from remote dockerhub) in an interactive mode to inspect the container and the application what is dockerized.

```
docker run -it mptbootcamp/nginx /bin/bash
hostname
cd /var/www/html
ls -ltr
cat index.html
```

2. Run the container as a daemon. 

```
docker run -d -p 8080:80 --name nginx mptbootcamp/nginx
```

In this case, it will run the command you specified when you build the image after the container is loaded by the Docker engine.

```
CMD /apps/nginx/bin/startup.sh
```

Now open the URL to from the browser.

```
http://console<n>.missionpeaktechnologies.com:8080
```

3. Now run the dockerized Java application.
```
docker run -d -p 9000:9000 --name assets-manager mptbootcamp/assets-manager
```

```
http://console<n>.missionpeaktechnologies.com:9000
```

In practice, you will build and push the container images to your private repository, then deploy them to various environments (dev, qa, uat, staging, prod). For example, you can push a image to Artifactory or Nexus using the following commands (provided you have a login id and password. Current Docker only support username/password, no SSH key pair support).

```
docker login <private-registry-url>
docker push <image tag>[:<version>]
```

See command options:

```
docker login --help
docker push -h
```

4. Running remote container images

In this exercise, let's run a Jenkins container image in the public Docker Hub registry. Of course you use your private registry as well if you have access to it.

```conseole
docker pull index.docker.io/jenkins
docker run -d -p 8080:8080 -p 50000:50000 --name jenkings jenkins
```

Now, open the URL to connect to the Jenkins container.

```
http://console<n>.missionpeaktechnologies.com:8080
```

Note, on your console terminal, it will print the initial login password like below:

```
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

ea0eea27c23c426aa134c0cccf03e178

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

### Execise 4 - Managing the lifecycle of containers and images.

By now you should have three containers running:

* mptbootcamp/nginx
* mptbootcamp/assets-manager
* jenkins

Run this command to see all running and stopped containers

```console
docker container ls -a
```

1. Stopping a running container or all containers

```console
docker container stop mptbootcamp/nginx
docker container stop $(docker container ls -q)
docker contaner rm mptbootcamp/nginx
docker container prune -f
```

To see all available commands and their options to manage the container lifecylle,

```console
docker container --help
docker container start --help
```

2. Cleaning up the container images

Once containers are stopped and deleted, it is the best practice to remove the associated container images as well. Let's now remote all stopped container images. To remove an image, you need to find out the image ID first, or use a trick like below.

```console
docker image ls -a
docker image rm $(docker image ls -q mptbootcamp/nginx)
docker image rm $(docker image ls -q)
```

You can also to remove all images with not associated containers (running or stopped)

```console
docker image prunce --help
docker image prune -a -f
```

### Conclusion

In this lab, you have learned the basic on how to build or dockerize an application in a machine (phyical or virtual) with the Docker Engine and tools installed. You also learn how to run and deploy your containerized applications and manage their lifecycle. Next you will see how to run containers on a Kubernete cluster instead of a Docker machine.