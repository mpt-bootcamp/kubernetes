## Lab3

aws ec2 describe-availability-zones --region us-east-1
aws s3 ls s3://mpt-kops
aws route53 list-hosted-zones-by-name

AWS Permission
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
AmazonEC2ContainerServiceFullAccess
PowerUserAccess

Need to create NS record for lab.missionpeaktechnologies.com in parent domain missionpeaktechnologies.com 

aws iam list-instance-profiles
kops get cluster --state=s3://mpt-kops


Note, need to fix the permission in the provision script
sudo chown -R student1: .ssh

```console
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "${USER}" -N "" -f id_rsa
cd ~/bootcamp/kubernetes
```


Step 1 - Creating the cluster configuration
```console
kops create cluster --name=student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops --zones=us-east-1a
```

The output should look like below:
```
I1230 17:05:12.043924   29162 create_cluster.go:517] Inferred --cloud=aws from zone "us-east-1a"
I1230 17:05:12.424560   29162 subnets.go:184] Assigned CIDR 172.20.32.0/19 to subnet us-east-1a
I1230 17:05:15.148071   29162 create_cluster.go:1496] Using SSH public key: /Users/issacl/.ssh/id_rsa.pub
Previewing changes that will be made:


error doing DNS lookup for NS records for "lab.missionpeaktechnologies.com": lookup lab.missionpeaktechnologies.com on 192.168.200.201:53: no such host
```

Step2 - Edit cluster, node, master

kops edit cluster student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops
kops edit ig --name=student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops nodes
kops edit ig --name=student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops master-us-east-1a


kops update cluster student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops --yes
```

Cluster is starting.  It should be ready in a few minutes.

Suggestions:
 * validate cluster: kops validate cluster
 * list nodes: kubectl get nodes --show-labels
 * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.student1.lab.missionpeaktechnologies.com
 * the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
 * read about installing addons at: https://github.com/kubernetes/kops/blob/master/docs/addons.md.


Step 3 - Validate cluster

$ kops validate cluster --state=s3://mpt-kops
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

It will take about 5-10 minutes for the cluster to be ready


$ kops validate cluster --state=s3://mpt-kops
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

Step 4 - Get Cluster and Nodes Information

$ kubectl get nodes
NAME                            STATUS   ROLES    AGE   VERSION
ip-172-20-35-134.ec2.internal   Ready    master   16m   v1.15.6
ip-172-20-52-39.ec2.internal    Ready    node     14m   v1.15.6
ip-172-20-60-65.ec2.internal    Ready    node     14m   v1.15.6

$ kubectl cluster-info
Kubernetes master is running at https://api.student1.lab.missionpeaktechnologies.com
KubeDNS is running at https://api.student1.lab.missionpeaktechnologies.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

$ kubectl -n kube-system get pods
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

$ kubectl config view


Step 5 - Deploy an Nginx Server

student1@console1:~/bootcamp/kubernetes$ kubectl create -f nginx/nginx-deploy.yaml
deployment.apps/nginx created
student1@console1:~/bootcamp/kubernetes$ kubectl create -f nginx/nginx-svc.yaml
service/nginx-elb created


$ kubectl create -f nginx_deploy.yaml

$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6f6d9b887f-g8jvv   1/1     Running   0          36s



Step 6 - Creating a Load Balancer Service

We can use annotations to set what type of load balancer we want (in this case a Network Load Balancer), SSL certificates etc.

$ kubectl create -f nginx_svc.yaml
service/nginx-elb created

$ kubectl describe svc nginx-elb
Name:                     nginx-elb
Namespace:                default
Labels:                   <none>
Annotations:              service.beta.kubernetes.io/aws-load-balancer-type: nlb
Selector:                 app=nginx
Type:                     LoadBalancer
IP:                       100.67.145.90
LoadBalancer Ingress:     a6fd2e98109ea4c28ab9a9ac61143ff5-f0060bc6a6df34c4.elb.us-east-1.amazonaws.com
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 http  31441/TCP
Endpoints:                100.96.2.3:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  44s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   42s   service-controller  Ensured load balancer


Step 6 - Access Nginx

Use the browser to open the LoadBalancer Ingress URL in step 5


LoadBalancer Ingress:     a6fd2e98109ea4c28ab9a9ac61143ff5-f0060bc6a6df34c4.elb.us-east-1.amazonaws.com


Step 7 - Get Admin password and Token

$ kops get secrets kube --type secret -o plaintext --state=s3://mpt-kops
$ kops get secrets admin --type secret -oplaintext --state=s3://mpt-kops

Step 8 - Access K8s dasbhboard
https://github.com/kubernetes/dashboard

Deploy dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

$ kubectl cluster-info
$ kubectl proxy
Starting to serve on 127.0.0.1:8001

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/


https://www.thehumblelab.com/deploying-kubernetes-dashboard-in-the-lab/

$ kubectl get service
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP                                                                     PORT(S)        AGE
kubernetes   ClusterIP      100.64.0.1      <none>                                                                          443/TCP        156m
nginx-elb    LoadBalancer   100.67.145.90   a6fd2e98109ea4c28ab9a9ac61143ff5-f0060bc6a6df34c4.elb.us-east-1.amazonaws.com   80:31441/TCP   121m

KOPS Cheat Sheet

https://lzone.de/cheat-sheet/kops
https://www.devops.buzz/public/kops/cheat-sheet


master-us-east-1a	Master	c4.large	1	1	us-east-1a
nodes			Node	t2.medium	2	2	us-east-1a


Delete cluster
kops get cluster --state=s3://mpt-kops
$ kops delete cluster ${NAME} --yes 

kops delete cluster student1.lab.missionpeaktechnologies.com --state=s3://mpt-kops--yes


Kubernetes Configuration
https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/





