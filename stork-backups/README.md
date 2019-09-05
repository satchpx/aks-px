# Using Stork to perform backups

## Pre-requisites
* Note: The pre-requisites are needed only with the private  build. With Portworx version 2.2 and Stork 2.3 GA, the steps below will not be required 

### 1. Update stork
```
kubectl -n kube-system set image deploy/stork stork=disrani/stork:2.3-dev  --record=true
```

### 2. Update Portworx
```
kubectl -n kube-system set image ds/portworx portworx=portworx/oci-monitor:2.2.0-rc1  --record=true
```

### 3. Update stork-role permissions
kubectl edit clusterrole -n kube-system stork-role
```
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
```

kubectl edit clusterrole -n kube-system node-get-put-list-role
```
- apiGroups:
  - "stork.libopenstorage.org"
  resources:
  - '*'
  verbs:
  - get
  - list
```

## Below are the scenarios we'll run through (Refer to the appropriate directory)
1. [Backup and restore in the same namespace](https://github.com/satchpx/aks-px/tree/master/stork-backups/1)
2. [Backup Namespaces from one cluster and restore on another cluster](https://github.com/satchpx/aks-px/tree/master/stork-backups/2)
3. [Backup a Namespace and Restore it in a different Namespace](https://github.com/satchpx/aks-px/tree/master/stork-backups/3)
4. [Backup a Namespace in one Cluster and Restore it on another Cluster](https://github.com/satchpx/aks-px/tree/master/stork-backups/4)
5. [Create BackupSchedule and restore from a periodic backup](https://github.com/satchpx/aks-px/tree/master/stork-backups/5)
