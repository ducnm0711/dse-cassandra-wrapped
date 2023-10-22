## Prerequisite

- Add repo and list all supported version
```
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm search repo k8ssandra/cass-operator --versions
$ helm search repo k8ssandra/cass-operator --versions
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
k8ssandra/cass-operator 0.44.1          1.17.2          Kubernetes operator which handles the provision...
...
k8ssandra/cass-operator 0.29.4          1.7.1           Kubernetes operator which handles the provision...
k8ssandra/cass-operator 0.29.2          1.7.1           Kubernetes operator which handles the provision...
k8ssandra/cass-operator 0.29.1          1.6.0           Kubernetes operator which handles the provision...
```

- We will start with chartversion 0.29.1 with image version 1.6.0

```
helm install cass-operator k8ssandra/cass-operator -n cass-operator --version 0.29.1
```

k get crd |grep k8ssandra | awk '{system("kubectl delete crd " $1)}'

## Upgrade options

`[chart version]-[cass-operator version]`
### Update EKS03 CRD
- Breaking change upgrade CRD can cause CassandraDatacenter resource to be cleaned --> Cluster shutdown + Data loss. We did a hack to edit the CRD only.
- Current nexus CRD is based on 0.29.0-1.6.0 with some manual modification `apiextensions.k8s.io/v1beta1` --> `apiextensions.k8s.io/v1`
- The latest CRD version we can update without major breaking change is `0.33-1.9.0`

### Fresh EKS06 CRD
- From `0.35.0-1.10.0` CRD format changed. For fresh EKS 1.25 installation we can use `0.44.1-1.17.2`