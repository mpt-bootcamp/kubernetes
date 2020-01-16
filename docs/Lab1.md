## Lab1

### Exercise 1 - Installing Nginx on a VM

This purpose of this exercise is show a traditional way to deploy Nginx on a barebone or virtual machine.

1. From your console machine's terminal window, SSH into the worker VM to install Nginx.

```console
ssh -i ~/.ssh/id_rsa_ubuntu ubuntu@worker1.lab.mpt.local
sudo apt-get update
sudo apt-get install nginx
sudo systemctl status nginx
curl http://localhost
```

2. Since the worker VM has a public IP address and domain name, you can access the Nginx web server from external directly with the URL below. If the VM is not in the public subnet, you will need to use a proxy or load balancer. 

```
http://worker1.missionpeaktechnologies.com
```


### Exercise 2 - Dockerize Nginx

To deploy and run Nginx as a container, you'll need to create (or dockerize) a container image first. Instead of creating a project directory and files from scratch, we will clone this bootcamp project from GitHub.

1. From your console machine's terminal window, execute the following commands.

```console
cd ~/bootcamp/
git clone https://github.com/mpt-bootcamp/kubernetes.git
cd kubernetes
cat nginx/Dockerfile
```

2. Run the following commands in the console terminal to build the Nginx container image.

```console
cd ~/bootcamp/kubernetes
docker build -t mptbootcamp/nginx ./nginx
docker image ls -a
docker history mptbootcamp/nginx
```

### Exercise 3 - Run Nginx as a container

From the console terminal window, enter this command line to run the container in the interactive mode.

```
docker run -it mptbootcamp/nginx /bin/bash
hostname
cd /var/www/html
ls -ltr
cat index.html
```

Now, let's run Ngnix in the container as a daemon.

```
docker run -d -p 8080:80 --name nginx mptbootcamp/nginx
```

From your browser, open the following URL

```
http://console<n>.missionpeaktechnologies.com:8080
```


### Execise 4 - Cleanup


```consoel
docker container ls -a
docker container stop nginx
docker container ls -a
docker container prune 

docker image ls -a
docker image rm <image id>
docker image prune -a -f
docker image ls -a
```
