# Using Stork to perform backups

## Pre-requisites
### 1. Install Portworx and Stork
```
https://docs.portworx.com/portworx-install-with-kubernetes/#installation
```

### 2. Verify
```
kubectl -n kube-system get ds portworx
kubectl -n kube-system get deploy stork
```


## Below are the scenarios we'll run through
1. [Backup and restore in the same namespace](https://github.com/satchpx/aks-px/tree/master/stork-backups/1)
2. [Backup Namespaces from one cluster and restore on another cluster](https://github.com/satchpx/aks-px/tree/master/stork-backups/2)
3. [Backup a Namespace and Restore it in a different Namespace](https://github.com/satchpx/aks-px/tree/master/stork-backups/3)
4. [Backup a Namespace in one Cluster and Restore it on another Cluster](https://github.com/satchpx/aks-px/tree/master/stork-backups/4)
5. [Create BackupSchedule and restore from a periodic backup](https://github.com/satchpx/aks-px/tree/master/stork-backups/5)
