# Using Stork to perform backups

## Pre-requisites

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
```
1. Create ApplicationBackup -> delete apps in that namespace -> create ApplicationRestore
2. Create ApplicationBackup to backup all namespaces in a cluster -> Restore it in a different cluster
3. Create ApplicationBackup of a namespace -> Restore it in another namespace
4. Create ApplicationBackup of a namespace in one cluster -> Restore it to another cluster
5. Test ApplicationBackupSchedule -> Restore a single namespace
```