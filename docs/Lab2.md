## Lab2 - Using Minikube to create a Kubernetes cluster

Minikube is a tool that lets you run a Kubernetes cluster locally. Minikube runs a single-node Kubernetes cluster inside a Virtual Machine (VM) on your laptop. 

Minikube requires to start as a root for Linux(Ubuntu. In this bootcamp, the following Kubernetes tools are already installed:

1. Minikube
2. Kutectl
3. Kops
4. Helm
5. AWS CLI

### Exercise 1 - Start a minikube cluster

From the console terminal window, execute the following commands to start Minikute and get information about it.

```console
sudo minikube start --vm-driver=none
```

This these commands not work with vm-driver=none in linux. Instead use the standard docker command
sudo minikube ssh
minikube docker-env
minikube ip


Once started, you can interact with your local cluster using kubectl, just like any other Kubernetes cluster.


### Exercixse 2 - 

Exposing a service as a NodePort

kubectl expose deployment nginx --type=NodePort --port=8080

minikube makes it easy to open this exposed endpoint in your browser:

minikube service nginx

Start a second local cluster (note: This will not work if minikube is using the bare-metal/none driver):

minikube start -p minikube2

Stop your local cluster:

minikube stop

Delete your local cluster:

minikube delete

Delete all local clusters and profiles

minikube delete --all



###
On AWS EC2

student2@console2:~/bootcamp/kubernetes$ sudo kubectl get services
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1      <none>        443/TCP        10m
nginx-elb    LoadBalancer   10.96.35.117   <pending>     80:31763/TCP   6m2s

http://console2.missionpeaktechnologies.com:31763
