## Lab2 - Using Minikube to create a Kubernetes cluster

In this lab, you will learn how to use Minikube to create a local Kubernetes cluster so that you can test your container deployment. Minikube runs a single-node Kubernetes cluster inside a Virtual Machine (VM) or your laptop. 

In this class, we already installed Minikube in the console machine. You can find intructions how to install Minikube [here](https://kubernetes.io/docs/tasks/tools/install-minikube/).


### Exercise 1 - Using Minikube CLI

Once Minikube is installed you can use the command line interface (CLI) to

* Start a cluster
* Show the status
* Configure the cluster
* Stop the cluster
* Delete the cluster


1. From the console terminal window, execute the following commands list the CLI commands and help

```console
sudo minikube --help
sudo minikube start -help
sudo minkkube config --help
sudo minkiube config set --help
```

2. To create or start a local cluster, 

```console
sudo minikube start --vm-driver=none
```

Here the *--vm-driver* option is set to *none* to tell Minikube to use the installed Docker engine instead of a hypervisor. Note, on MacOS, set the driver to *hyperkit* instead of *none*.

3. To show the cluster status or get information, use these commands:

```console
sudo minikube version
sudo minikube status
sudo minikube ip
sudo minikube logs
```


### Exercixse 2 - Creating a Nginx Pod

1. In this exercise, you create a Kubernetes Pod that contains our customized nginx container application, mptbootcamp/nginx, which we already push to the public Docker hub registry.

```console
cd ~/bootcamp/kubernetes
sudo kubectl create -f ./nginx/deployment.yaml
```

2. To see the deployment rollout status, run

```console
sudo kubectl rollout status deployment.apps/nginx
sudo kubectl get deployment
```

3. To see the running pod(s), run

```console
sudo kubectl get pods
sudo kubectl get pods --show-labels
```

Now, let review the Kubernetes Deployment manifest file, `./nginx/deployment.yaml`, that is pre-defined to create the pod.

```
# deployment.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 1
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

Exercuse 2 - Exposing the Nginx Pod Service

By default, the Pod is only accessible by its internal IP address within the Kubernetes cluster. To make the pod accessible from outside, you have to expose the Pod as a Kubernetes Service using the pre-defined manifest file.

**./nginx/service.yaml**
```
# service.yaml
kind: Service
apiVersion: v1

metadata:
  name: nginx
  namespace: default

spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - name: http
      port: 8080
      targetPort: 80
```

1. To create the service, run
```console
cd ~/bootcamp/kubernetes
sudo kubectl create -f ./nginx/service.yaml
```

2. View the serivce just dreated.
```console
sudo kubectl get services
```

Note the target port (8080) exposed is 31262 in this example. You will use this port the the Minikube cluster IP to access the Ngnix pod.

```
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP          12m
nginx            NodePort    10.96.53.91    <none>        8080:31034/TCP   9m37s
```

With the exposed port and the cluster IP, open the URL from the browser. For example

```
http://console1.missionpeaktechnologies.com:31034/
```


### Exercise 3 - Creating the Java Application Pod 

Let's repeat the steps in Exercise 2 to deploy a Java application pod, assets-manager.

```console
cd ~/bootcamp/kubernetes
sudo kubectl create -f ./assets-manager/deployment.yaml
sudo kubectl create -f ./assets-manager/service.yaml
sudo kubectl get pods
sudo kubectl get services
```

```
student1@console1:~/bootcamp/kubernetes$ sudo kubectl get services
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
assets-manager   NodePort    10.96.25.160   <none>        9000:31171/TCP   44s
kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP          12m
nginx            NodePort    10.96.53.91    <none>        8080:31034/TCP   9m37s
```


Note, the exposed service port, like the Nginx pod. Open the URL to access the Java application. For example

```
http://console1.missionpeaktechnologies.com:31171/
```



### Exercise 4 - Removing Services and Pods

1. To stop a pod, you can set the replicas count to 0. For exmaple,

```console
sudo kubectl scale --replicas=0 deployment/assets-manager
sudo kubectl get pods
```

You should see the **STATUS** change Terminating, or not show up once it is terminated.

2. To delete the rest of services and pods, run

```console
sudo kubectl get services 
sudo kubectl delete service assets-manager
sudo kubectl delete service nginx
sudo kubectl get pods
sudo kubectl delete pod <pod-name>
```

### Exercise 5 - Deleting the Local Minikube Cluster

When you are done with the cluster, you can run the delete command to remove the local custer.

```console
sudo minikube status
sudo minikube delete
````

### Conclusion

In this lab, you learn how to create and delete a local Kubernetes cluster using Minikube. You also learn how to create pods and services using **kubectl** CLI and manifest files.

In the next lab, we will create a production Kubernetes cluster in AWS using the **kops** CLI.


