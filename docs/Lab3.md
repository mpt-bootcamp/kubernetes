## Lab3 - Creating a Production Kubernetes Cluster using Kops

https://kubernetes.io/docs/home/


Kops allows deployment of highly available Kubernetes clusters on AWS and Google (GCP) clouds. It doesn't yet support on-premise infrastructure like VMware or OpenStack. For on prem deployment, you can use the **kubeadm** toolkit.

#### Key Features

* Deploy clusters to existing virtual private clouds (VPC) or create a new VPC from scratch
* Supports public & private topologies
* Provisions single or multiple master clusters
* Configurable bastion machines for SSH access to individual cluster nodes
* Rolling cluster updates


In this lab, we will walk through the steps to spin up a Kubernetes cluster in AWS using Kops. To use Kops, we already:

1. Installed kops and kubectl
2. Created a route53 domain, **lab.missionpeaktechnologies.com**
3. Created a S3 bucket to store the cluster state, **s3://mpt-kops**
4. Added the AWS credentials, ~/.aws/credentials
5. Granted the IAM permissions
```
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
AmazonEC2ContainerServiceFullAccess
PowerUserAccess
```

### Exercise 1 - Verifying the AWS Environment

From you console terminal window, run 
Note: If you are under root, please exit root by execute 'exit' command
```console
cd ~/bootcamp/kubernetes
aws ec2 describe-availability-zones --region us-east-1
aws s3 ls s3://mpt-kops
aws route53 list-hosted-zones-by-name
aws iam list-instance-profiles
kops get cluster --state=s3://mpt-kops
kops --help
kubectl --help
```

Note, need to fix the permission in the provision script
sudo chown -R student1: .ssh

### Exercise 2 - Generating a SSH Key Pair 

Create a ssh key pair that is required to create kubernetes cluster in AWS. This will enable you to connect to the cluster master and worker.

```console
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "${USER}" -N "" -f id_rsa
cd ~/bootcamp/kubernetes
```


### Exercise 3 - Creating a Cluster Configuration

**NOTE** to replace \<n\> with your assigned student number.

```console
sudo kops create cluster --name=student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops --zones=us-east-1a
```

The output should look like below:
```
I1230 17:05:12.043924   29162 create_cluster.go:517] Inferred --cloud=aws from zone "us-east-1a"
I1230 17:05:12.424560   29162 subnets.go:184] Assigned CIDR 172.20.32.0/19 to subnet us-east-1a
I1230 17:05:15.148071   29162 create_cluster.go:1496] Using SSH public key: /Users/issacl/.ssh/id_rsa.pub
Previewing changes that will be made:


error doing DNS lookup for NS records for "lab.missionpeaktechnologies.com": lookup lab.missionpeaktechnologies.com on 192.168.200.201:53: no such host
```

### Exercise 3 (Optional) -  Edit the Cluster, Master, and Worker Node Group Configuration 

After you create the custer configuration, you can edit the configuration before you spin up the cluster. 
```console
kops edit cluster student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops
kops edit ig --name=student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops nodes
kops edit ig --name=student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops master-us-east-1a
```

### Exercise 4 - Creating the AWS Cluster

Run the kops update command to create the cluster using the configuration object created. **NOTE**, you need to use sudo to escalate the privilege to create the cluster.

```console
sudo kops update cluster student<n>.lab.missionpeaktechnologies.com --state=s3://mpt-kops --yes
```

Cluster is starting. It should be ready in a few minutes (5 - 10 minutes).

### Exercise 5 - Validating the Created Cluster

To validate the cluster is ready to use, run 

```console
sudo kops validate cluster --state=s3://mpt-kops
```

You should see somethings like below while the cluster is creating.

```
Using cluster from kubectl context: student1.lab.missionpeaktechnologies.com

Validating cluster student1.lab.missionpeaktechnologies.com

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
master-us-east-1a	Master	c4.large	1	1	us-east-1a
nodes			Node	t2.medium	2	2	us-east-1a

NODE STATUS
NAME	ROLE	READY

VALIDATION ERRORS
KIND	NAME		MESSAGE
dns	apiserver	Validation Failed

The dns-controller Kubernetes deployment has not updated the Kubernetes cluster's API DNS entry to the correct IP address.  The API DNS IP address is the placeholder address that kops creates: 203.0.113.123.  Please wait about 5-10 minutes for a master to start, dns-controller to launch, and DNS to propagate.  The protokube container and dns-controller deployment logs may contain more diagnostic information.  Etcd and the API DNS entries must be updated for a kops Kubernetes cluster to start.

Validation Failed

```

It will take about 5-10 minutes for the cluster to be ready. If the cluster is ready for use, it looks like below:

```
Using cluster from kubectl context: student1.lab.missionpeaktechnologies.com

Validating cluster student1.lab.missionpeaktechnologies.com

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
master-us-east-1a	Master	c4.large	1	1	us-east-1a
nodes			Node	t2.medium	2	2	us-east-1a

NODE STATUS
NAME				ROLE	READY
ip-172-20-35-134.ec2.internal	master	True
ip-172-20-52-39.ec2.internal	node	True
ip-172-20-60-65.ec2.internal	node	True

Your cluster student1.lab.missionpeaktechnologies.com is ready
```

### Exercise 6 - Getting Information About the Cluster

1. Getting the cluster information
```console
sudo kubectl config get-contexts
sudo kubectl config get-clusters
sudo kubectl cluster-info
```

If you have multiple clusters, you can use this command to switch. For example,
```console
sudo kubectl config use-context student1.lab.missionpeaktechnologies.com
```

**Example Output:**
```
Kubernetes master is running at https://api.student1.lab.missionpeaktechnologies.com
KubeDNS is running at https://api.student1.lab.missionpeaktechnologies.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

2. Getting the master and worker nodes information
```console
sudo kubectl get nodes
```
**Example Ouput:**
```
NAME                            STATUS   ROLES    AGE   VERSION
ip-172-20-35-134.ec2.internal   Ready    master   16m   v1.15.6
ip-172-20-52-39.ec2.internal    Ready    node     14m   v1.15.6
ip-172-20-60-65.ec2.internal    Ready    node     14m   v1.15.6
```

3. Getting the running system pods of the cluster
```console
sudo kubectl -n kube-system get pods
```
**Sample Output:**
```
NAME                                                    READY   STATUS    RESTARTS   AGE
dns-controller-5679f577f7-xlb85                         1/1     Running   0          25m
etcd-manager-events-ip-172-20-35-134.ec2.internal       1/1     Running   0          24m
etcd-manager-main-ip-172-20-35-134.ec2.internal         1/1     Running   0          24m
kube-apiserver-ip-172-20-35-134.ec2.internal            1/1     Running   2          24m
kube-controller-manager-ip-172-20-35-134.ec2.internal   1/1     Running   0          25m
kube-dns-5fdb85bb5b-5p8tf                               3/3     Running   0          25m
kube-dns-5fdb85bb5b-nxqrf                               3/3     Running   1          23m
kube-dns-autoscaler-577b4774b5-9srdf                    1/1     Running   0          25m
kube-proxy-ip-172-20-35-134.ec2.internal                1/1     Running   0          25m
kube-proxy-ip-172-20-52-39.ec2.internal                 1/1     Running   0          23m
kube-proxy-ip-172-20-60-65.ec2.internal                 1/1     Running   0          22m
kube-scheduler-ip-172-20-35-134.ec2.internal            1/1     Running   0          25m
```

### Exercise 7 - Deploying Container Applications

1. Deploying the Nginx Application

```console
cd ~/bootcamp/kubernetes
sudo kubectl create -f ./nginx/deployment.yaml
sudo kubectl create -f ./nginx/service.yaml
sudo kubectl create -f ./nginx/service-elb.yaml
sudo kubectl get pods
sudo kubectl get services
```

2. Deploying the Java Application

```console
cd ~/bootcamp/kubernetes
sudo kubectl create -f ./assets-manager/deployment.yaml
sudo kubectl create -f ./assets-manager/service.yaml
sudo kubectl create -f ./assets-manager/service-elb.yaml
sudo kubectl get pods
sudo kubectl get services
```

3. Accessing the Applications.

Note the LoadBalancer URL from the ```sudo kubectl get services```. For example,

```
student1@console1:~/bootcamp/kubernetes$ sudo kubectl get services
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)          AGE
assets-manager       NodePort       100.64.254.102   <none>                                                                          9000:30907/TCP   38m
assets-manager-elb   LoadBalancer   100.69.97.76     ad13c01588797498489de0eaa839d164-ed92c979af7613b2.elb.us-east-1.amazonaws.com   9000:31530/TCP   8s
kubernetes           ClusterIP      100.64.0.1       <none>                                                                          443/TCP          47m
nginx                NodePort       100.64.30.204    <none>                                                                          8080:32433/TCP   38m
nginx-elb            LoadBalancer   100.66.154.18    ab97653e885ad4b4398c833d0d3c67c5-684d3571c9ae52a8.elb.us-east-1.amazonaws.com   80:31028/TCP     42s
```


Open the URLs from the browser for each of the LoadBalancer URLs. **NOTE** it will take a while for the AWS ELB DNS to propergate (~10 minutes). For example,

```
http://ab97653e885ad4b4398c833d0d3c67c5-684d3571c9ae52a8.elb.us-east-1.amazonaws.com
http://ad13c01588797498489de0eaa839d164-ed92c979af7613b2.elb.us-east-1.amazonaws.com:9000
```





### Exercise 8 - Stopping Pods, Deleting Services and Cluster

Stopping and deleting the pods and serivces are no different than Minikube.

1. Stopping and deleting the pods and services
```console
sudo kubectl get services 
sudo kubectl delete service assets-manager
sudo kubectl delete service assets-manager-elb
sudo kubectl delete service nginx
sudo kubectl delete service nginx-elb

sudo kubectl delete deployment assets-manager
sudo kubectl delete deployment nginx
sudo kubectl get pods
```

For example,
```
student1@console1:~/bootcamp/kubernetes$ sudo kubectl get pods
NAME                              READY   STATUS        RESTARTS   AGE
assets-manager-6455585c99-6z4qs   1/1     Terminating   0          5m31s
nginx-664d65797b-q6jkd            1/1     Terminating   0          57m
```

### Conclusion

In this lab, we walked through the steps to create a production Kubernetes cluster using Kops. Using the **kubectl** CLI, you deployed the Nginx and Java applications using the manifest files the same way as you deployed to your local Minikube cluster. 

In the last last lab, we will learn a different way to package, deploy and scale container applications using Helm.






