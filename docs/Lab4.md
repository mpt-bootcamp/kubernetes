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

### Exercise 3 - Deploying charts to a local Minikube cluster



### Exercise 4 - Deploying charts to the Kops cluster



Before we get started, let's ensure we have both the Minikube and Kops clusters running:

```console
sudo kubectl config get-contexts
```

For example,

```
student1@console1:~/bootcamp/kubernetes$ sudo kubectl config get-contexts
CURRENT   NAME                                       CLUSTER                                    AUTHINFO                                   NAMESPACE
          minikube                                   minikube                                   minikube                                   
*         student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   student1.lab.missionpeaktechnologies.com   


```
**Note**: The asterisk (\*) indicates the current context or cluster.

If you aready deleted the Minikube from Lab2, you can recreate it back 

```console
sudo minikube start --vm-driver=none
```

Let's now select the Minikube cluster.
```console
sudo kubectl config use-context minikube
sudo kubectl cluster-info
```

### Exercise 1 - Using Helm Chart Repositories

A chart repository is a server that houses packaged charts. Any HTTP server that can serve YAML files and tar files can be used as your private repository server. Helm does not provide tools for uploading charts to remote repository servers. 

```
sudo helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

Otherwise you will get this error
``
student1@console1:~/bootcamp/kubernetes$ sudo helm search repo jenkins
Error: no repositories configured
```

1. To show the default repo
```console
sudo helm repo list 
sudo helm env
```
You can add your own private repo using this command
```
helm repo add <repo-name> <http-url>
```

2. To search for available charts,
```console
sudo helm search hub jenkins
sudo helm search repo jenkins
```

Hub comprises charts from different repositories. Repo searches only the repositories you added, like your private repo.

3. Download a public chart a chart and unpack it in a local directory

```console
cd ~/bootcamp/kubernetes
cd charts
sudo rm -rf jenkins
sudo helm fetch --untar stable/jenkins
tree
```

4. Installing a chart

To install the downloaded Jenkins chart,

```console
cd ~/bootcamp/kubernetes
cd charts
sudo helm install jenkins ./jenkins
```

5. To verify the install application is running

```console
sudo kubectl get pods
```

6. To list and get status of the installed application

```console
sudo helm list
sudo helm status jenkins
sudo helm history jenkins
```

7. Uninstall an application

```console
sudo helm list
sudo helm uninstall jenkins
sudo helm list
sudo kubectl get pods
```


### Exercise 2 - Creating a new chart

Creating a new nginx chart using the customized mptbootcamp/nginx container image.

1. Create a chart folder with the boilerplate
```console
cd ~/bootcamp/kubernetes
mkdir -p charts
cd charts
sudo helm create nginx
cd nginx
tree
```

The chart directory should like below:
```
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

2. To keep thing simple, let delete the following unused manifest files 
```console
cd ~/bootcamp/kubernetes/charts/nginx
rm templates/ingress.yaml
rm templates/serviceaccount.yaml
rm values.yaml
```

3. Replace the deployment and service manifest files we used in Lab 2 and 3 exercises.

```console
cd ~/bootcamp/kubernetes/charts/nginx
cp ~/bootcamp/kubernetes/nginx/deployment.yaml template/
cp ~/bootcamp/kubernetes/nginx/service.yaml template/
```

4. Install the new chart

```console
cd ~/bootcamp/kubernetes/charts
sudo helm install nginx ./nginx
sudo helm list
sudo kubectl get pods
```

5. Verify the install nginx pod is accessible.

```
student1@console1:~/bootcamp/kubernetes$ sudo kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          14m
nginx        NodePort    10.96.151.155   <none>        8080:30924/TCP   89s
```

```
http://console1.missionpeaktechnologies.com:30924/
```


Create a new chart
Install/uninstall a chart



If you have multiple clusters, you can use this command to switch. For example,
```console
sudo kubectl config use-context student1.lab.missionpeaktechnologies.com
```




Helm reserves use of the charts/, crds/, and templates/ directories, and of the listed file names

https://helm.sh/docs/chart_template_guide/

Exercise


helm create myapp
helm install myapp ./myapp --set service.type=NodePort
helm list
helm status myapp
helm show all myapp
helm get 
helm get manifest myapp
helm history myapp


kubectl get deployment
kubectl get services
kubectl get pods
helm upgrade myapp ./myapp --version=1.1 --set replicaCount=2 --set service.type=LoadBalancer
kubectl history myapp
kubectl get serivces
kubectl get pods
helm upgrade myapp ./myapp --version=1.2 --set replicaCount=3 --set service.type=LoadBalancer

```
kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-7f7f5c7b6f-99bhf   1/1     Running   0          28m
myapp-7f7f5c7b6f-ggffz   1/1     Running   0          43s
myapp-7f7f5c7b6f-srmmr   1/1     Running   0          7m3s
```

helm upgrade myapp ./myapp --version=1.3 --set replicaCount=1 --set service.type=LoadBalancer
kubectl get pods
helm history
helm rollback myapp <revision>
helm get pods
kubectl scale --replicas=0 deployment/myapp
helm list
kubectl scale --replicas=1 deployment/myapp
helm history myapp
helm uninstall myapp
helm history myapp


### Clean up

1. To delete the cluster,

```console
kops delete cluster student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops --yes
```

