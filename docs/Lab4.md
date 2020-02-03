## Lab4 - Using Helm for Packaging and Deployment

In this lab, you will learn how to use Helm to package and to deploy container applications to both local (Minikube) and production (AWS) Kubernetes clusters.

Helm is a package manager and deployment tool for Kubernetes. With Helm,

* There is no need to run individual command to create Kubernetes Objects. 
* Enable revision management
* Easy to manage application lifecycle - install, update, scale up and down, and uninstall applications
* Using templates to create complex and environment specific deployments


A Helm chart is just a collection of files inside of a directory. For example,

```
nginx/
  Chart.yaml          # A YAML file containing information about the chart
  LICENSE             # OPTIONAL: A plain text file containing the license for the chart
  README.md           # OPTIONAL: A human-readable README file
  values.yaml         # The default configuration values for this chart
  values.schema.json  # OPTIONAL: A JSON Schema for imposing a structure on the values.yaml file
  charts/             # A directory containing any charts upon which this chart depends.
  crds/               # Custom Resource Definitions
  templates/          # A directory of templates that, when combined with values,
                      # will generate valid Kubernetes manifest files.
  templates/NOTES.txt # OPTIONAL: A plain text file containing short usage notes
```

Kubernetes Objects are persistent entities in the cluster. These objects can be defined as chart files/templates to represent the state of the cluster. Some of the common Kubernetes Objects are:

* Pod
* Deployment
* ReplicaSet
* Namespace
* StatefulSet
* DaemonSet
* Service
* Ingress
* ConfigMap
* PersistenVolume
* PersitentVolumeClaim


In Lab 2 and 3, we use the ***create*** command to create the Nginx and the Java application Assets Manager using kubectl CLI.

> kubectl create -f ./nginx/deployment.yaml
> kubectl create -f ./nginx/service.yaml
> kubectl create -f ./nginx/service-elb.yaml
> kubectl create -f ./assets-manager/deployment.yaml
> kubectl create -f ./assets-manager/service.yaml
> kubectl create -f ./assets-manager/service-elb.yaml

In this last lab, you will learn how to create the charts for the Nginx and Java Assets Manager applications and deploy them to both the local and production clusters.


### Exercise 1 - Creating the Nginx chart.

1. Creating a chart boilerplate
```console
cd ~/bootcamp/kubernetes
mkdir -p charts
cd charts
sudo helm create nginx
cd nginx
rm -rf templates/*
tree
```

2. Adding the deployment and service manifest chart files.

Let's copy the manifest files we use in Lab 2 and Lab 3 instead of recreating them.

```console
cd ~/bootcamp/kubernetes/charts/nginx
cp ~/bootcamp/kubernetes/nginx/*.yaml templates
d ~/bootcamp/kubernetes/charts
tree
```

The Nginx chart should look like this:

```
└── nginx
    ├── Chart.yaml
    ├── charts
    ├── templates
    │   ├── deployment.yaml
    │   ├── service-elb.yaml
    │   └── service.yaml
    └── values.yaml
```

### Exercise 2 - Creating the Assets Manager chart.

1. Creating a chart boilerplate
```console
cd ~/bootcamp/kubernetes/charts
sudo helm create assets-manager
cd assets-manager
rm -rf templates/*
tree
```

2. Adding the deployment and service manifest chart files.

```console
cd ~/bootcamp/kubernetes/charts/assets-manager
cp ~/bootcamp/kubernetes/assets-manager/*.yaml templates
cd ~/bootcamp/kubernetes/assets-manager
tree
```

The chart should look like this:

```
└── assets-manager
    ├── Chart.yaml
    ├── charts
    ├── templates
    │   ├── deployment.yaml
    │   ├── service-elb.yaml
    │   └── service.yaml
    └── values.yaml
```

### Exercise 3 - Listing the running clusters

1. Listing the running clusters
```console
sudo kubectl config get-contexts
```

The output should look like below. Note the asterisk (\*) next to the line indicates the current cluster.
```
student1@console1:~$ sudo kubectl config get-contexts
CURRENT   NAME                                       CLUSTER                                    AUTHINFO                                   NAMESPACE
          minikube                                   minikube                                   minikube                                   
*         student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   

```

2. Selecting a running clster. 
```console
sudo kubectl config use-context minikube
```

You should see the active cluster is now minikube. You can switch back and forth between clusters.
```
student1@console1:~$ sudo kubectl config get-contexts
CURRENT   NAME                                       CLUSTER                                    AUTHINFO                                   NAMESPACE
*         minikube                                   minikube                                   minikube                                   
          student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   

```

### Exercise 4 - Deploying charts to a local Minikube cluster

1. Installing the Nginx and Java Application chart

```console
cd ~/bootcamp/kubernetes/charts
sudo helm install nginx ./nginx/
sudo helm install assets-manager ./assets-manager/
sudo helm list
sudo kubectl get pods
sudo kubectl get services
```

2. Accessing the application

To access the application on the Minikube, you need to obtain the mapping port number of either the NodePort or LoadBalancer. The IP address or hostname is your machine name.

> http://console<\n\>.missionpeaktechnologies.com


For example,
```
student1@console1:~/bootcamp/kubernetes/charts$ sudo kubectl get services
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
assets-manager       NodePort       10.96.107.179   <none>        9000:31171/TCP   20s
assets-manager-elb   LoadBalancer   10.96.244.154   <pending>     80:31534/TCP     20s
kubernetes           ClusterIP      10.96.0.1       <none>        443/TCP          63m
nginx                NodePort       10.96.235.239   <none>        8080:30278/TCP   34m
nginx-elb            LoadBalancer   10.96.152.227   <pending>     80:30895/TCP     34m
```

Open the URLs with your browser.

**NodePort:**
http://console1.missionpeaktechnologies.com:30278/
http://console1.missionpeaktechnologies.com:31171/

**LoadBalancer:**
http://console1.missionpeaktechnologies.com:30895/
http://console1.missionpeaktechnologies.com:31534/


### Exercise 4 - Deploying charts to the Kops cluster

Before deploying to the Kops cluster, you need to select the cluster. For example,

```console
sudo kubectl config use-context student1.lab.missionpeaktechnologies.com
sudo kubectl config get-contexts
```

```console
cd ~/bootcamp/kubernetes/charts
sudo helm install nginx ./nginx/
sudo helm install assets-manager ./assets-manager/
sudo helm list
sudo kubectl get pods
sudo kubectl get services
```

The output should show the services like below:

```
student1@console1:~/bootcamp/kubernetes/charts$ sudo kubectl get services
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)          AGE
assets-manager       NodePort       100.70.95.191    <none>                                                                          9000:31143/TCP   79s
assets-manager-elb   LoadBalancer   100.65.186.223   a2d3d11ed109b4b8f88ed76116c444b7-83d010f1460714a3.elb.us-east-1.amazonaws.com   80:32406/TCP     79s
kubernetes           ClusterIP      100.64.0.1       <none>                                                                          443/TCP          41m
nginx                NodePort       100.65.168.47    <none>                                                                          8080:30802/TCP   51s
nginx-elb            LoadBalancer   100.69.56.202    a6c1c506c02014e1194cf2016f5268d3-35651e9a6d4b5e1f.elb.us-east-1.amazonaws.com   80:31901/TCP     51s
```

For the Kops, you should see the name of the LoadBalancer URLs created. It will the the public DNS few minutes to propergate. Open the URL with our browser.

```
http://a2d3d11ed109b4b8f88ed76116c444b7-83d010f1460714a3.elb.us-east-1.amazonaws.com
http://a6c1c506c02014e1194cf2016f5268d3-35651e9a6d4b5e1f.elb.us-east-1.amazonaws.com
```


### Exercise 5 - Scaling up and down

Now, let's edit the Assets Manager chart to use variable for the ***replicas** attribute in the deployment.yaml manifest.

1. Parameterizing the manifest file.

```console
cd ~/bootcamp/kubernetes/charts/assets-manager
```

2. Edit template, template/deployment.yaml, and replace the line 

>   replicas: 1 

with

>   replicas: {{ .Values.replicaCount }}

```
# deployment.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx
  namespace: default
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: mptbootcamp/nginx:latest
        ports:
        - containerPort: 80
```

3. Now to scale up, run the following command

```console
cd ~/bootcamp/kubernetes/charts/
sudo helm upgrade assets-manager ./assets-manager --set replicaCount=3
```

4. Checking the new replicas

```
sudo kubectl get pods
```

You should see 3 pods for the assets-manager now
```
NAME                              READY   STATUS    RESTARTS   AGE
assets-manager-7466dcd895-4zb9w   1/1     Running   0          115s
assets-manager-7466dcd895-lw9zj   1/1     Running   0          39m
assets-manager-7466dcd895-mk6g9   1/1     Running   0          115s
nginx-68b9c474d8-bg6rp            1/1     Running   0          74m
```

5. Drain the number of pod to zero (0)

```
cd ~/bootcamp/kubernetes/charts/
sudo helm upgrade assets-manager ./assets-manager --set replicaCount=0
sudo kubectl get pods
```

**Output:**
```
assets-manager-7466dcd895-4zb9w   1/1     Terminating   0          5m12s
assets-manager-7466dcd895-lw9zj   1/1     Terminating   0          42m
assets-manager-7466dcd895-mk6g9   1/1     Terminating   0          5m12s
nginx-68b9c474d8-bg6rp            1/1     Running       0          77m

```

### Exercise 6 - Cleaning up

Now we see how to deploy charts to Kuberetes clusters. In this exercise, we will perform the clean up.

```console
cd ~/bootcamp/kubernetes/charts/
sudo helm list
sudo helm uninstall nginx
sudo helm uninstall assets-manager
sudo kubectl get services
sudo kubectl get pods
```

We will skip the uninstall on Minikube. For this Bootcamp, we need to delete the clusters with this command. MAKE SURE you use your assigned student number.

```console
sudo minikube delete
sudo kops delete cluster student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops --yes
```

