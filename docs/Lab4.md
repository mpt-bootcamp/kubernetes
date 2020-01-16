## Lab4

https://developer.ibm.com/blogs/kubernetes-helm-3/
https://github.com/alexellis/helm3-expressjs-tutorial
https://helm.sh/docs/intro/using_helm/
https://learnk8s.io/kubernetes-ingress-api-gateway


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




