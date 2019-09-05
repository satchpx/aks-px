# Scenario 1: Create ApplicationBackup and restore it in the same namespace

## Create BackupLocation
A BackupLocation can be used to specify the objectstore where the backup should be placed. The supported objectstores are: 

* Any S3 compliant objectstore
* Azure Blob storage
* Google Cloud Storage

The config values for BackupLocation are similar to what would be provided to pxctl cred create command.

The configuration for a BackupLocation can be provided inline in the spec or through a Kubernetes Secret.

Example S3 inline config
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: greatdane
  namespace: mysql
  annotations:
    stork.libopenstorage.org/skipresource: "true"
location:
  type: s3
  path: "stork-test"
  s3Config:
    region: us-east-1
    accessKeyID: CT6R80D3ST0VW9NY6HYP
    secretAccessKey: a0V6dPqu8C26KbAsa9qsIrfhsbvyGjjPPmZN2qD4
    endpoint: "70.0.0.141:9010"
    disableSSL: true
```

Example S3 config from a secret:
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: greatdane
  namespace: mysql
  annotations:
    stork.libopenstorage.org/skipresource: "true"
location:
  type: s3
  path: "stork-test"
  secretConfig: s3secret
---
apiVersion: v1
kind: Secret
metadata:
  name: s3secret
  namespace: mysql
  annotations:
    stork.libopenstorage.org/skipresource: "true"
stringData:
  region: us-east-1
  accessKeyID: CT6R80D3ST0VW9NY6HYP
  secretAccessKey: a0V6dPqu8C26KbAsa9qsIrfhsbvyGjjPPmZN2qD4
  endpoint: "70.0.0.141:9010"
  disableSSL: "true"
  encryptionKey: "testKey"
```

Example Azure config:
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: azure-backup
  namespace: mysql
  annotations:
    stork.libopenstorage.ord/skipresource: "true"
location:
  type: azure
  path: "pwx"
  azureConfig:
    storageAccountName: "<redacted>"
    storageAccountKey: "<redacted>"
```

## Create ApplicationBackup

Once a BackupLocation has been defined it can be used in an ApplicationBackup spec to backup the volumes and resources. If you are running in a non-admin namespace you can only backup the namespace where the object is created. In the admin namespace you can backup any namespace.

Similar to the other specs for Migration and Snapshots you can specify PreExec and PostExec rules that you want to run before and after a backup has been triggered.

For example if you have some apps running the mysql namespace, you can apply the following spec to backup all the resources from that namespace to the BackupLocation that we specified above.
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationBackup
metadata:
  name: backup
  namespace: mysql
spec:
  backupLocation: greatdane
  # namespaces to be backed up
  namespaces:
  - mysql
  # What to do with the data in the objectstore when the backup object in k8s is deleted. Valid options are Delete and Retain
  reclaimPolicy: Delete
  # List of label selectors to choose specific objects and volumes to backup
  selectors:
  # Rule to run before triggering the backup
  preExecRule:
  # Rule to run after the backup has been triggered
  postExecRule:
```

Once an ApplicationBackup object has been created you can use storkctl to check the status of the backup
```
$ storkctl get applicationbackup -n mysql
NAME      STAGE     STATUS       VOLUMES   RESOURCES   CREATED               ELAPSED
backup    Final     Successful   1/1       9           12 Jun 19 22:55 UTC   31s
```

You can also describe the object to get more information about the backup
```
$ kubectl describe applicationbackup.stork.libopenstorage.org -n mysql
Name:         backup
Namespace:    mysql
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"ApplicationBackup","metadata":{"annotations":{},"name":"backup","namespace":"mys...
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         ApplicationBackup
Metadata:
  Creation Timestamp:  2019-05-29T02:07:14Z
  Generation:          1
  Resource Version:    57252334
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/mysql/applicationbackups/backup
  UID:                 7a6912a4-81b6-11e9-9c67-0214683e8447
Spec:
  Backup Location:  greatdane
  Namespaces:
    mysql
  Post Exec Rule: 
  Pre Exec Rule:  
  Reclaim Policy:  Delete
  Selectors:       <nil>
Status:
  Backup Path:       mysql/backup/7a6912a4-81b6-11e9-9c67-0214683e8447
  Finish Timestamp:  2019-05-29T02:07:43Z
  Resources:
    Group:      core
    Kind:       PersistentVolume
    Name:       pvc-23874365-78e5-11e9-9c67-0214683e8447
    Namespace: 
    Version:    v1
    Group:      core
    Kind:       PersistentVolumeClaim
    Name:       mysql-data
    Namespace:  mysql
    Version:    v1
    Group:      core
    Kind:       Secret
    Name:       mysql-account-token-tbwg5
    Namespace:  mysql
    Version:    v1
    Group:      core
    Kind:       Secret
    Name:       s3secret
    Namespace:  mysql
    Version:    v1
    Group:      core
    Kind:       Service
    Name:       mysql
    Namespace:  mysql
    Version:    v1
    Group:      core
    Kind:       ServiceAccount
    Name:       mysql-account
    Namespace:  mysql
    Version:    v1
    Group:      apps
    Kind:       Deployment
    Name:       mysql
    Namespace:  mysql
    Version:    v1
    Group:      rbac.authorization.k8s.io
    Kind:       ClusterRoleBinding
    Name:       mysql-role-binding
    Namespace: 
    Version:    v1
    Group:      rbac.authorization.k8s.io
    Kind:       ClusterRole
    Name:       mysql-role
    Namespace: 
    Version:    v1
  Stage:        Final
  Status:       Successful
  Volumes:
    Backup ID:                stork-test/58382378687020283-75826665008750969
    Namespace:                mysql
    Persistent Volume Claim:  mysql-data
    Reason:                   Backup successful for volume
    Status:                   Successful
    Volume:                   pvc-23874365-78e5-11e9-9c67-0214683e8447
Events:
  Type    Reason      Age   From   Message
  ----    ------      ----  ----   -------
  Normal  Successful  10s   stork  Volume pvc-23874365-78e5-11e9-9c67-0214683e8447 backed up successfully
```
If there are any errors you should see events raised for the object.

## Create ApplicationRestore

Once an application has been backed up it can be used as a source for restores. By default, users can only restore to their namespace. Only an AdminNamespace can be used to restore to other namespaces.

For the above backup, a restore can be done by using the following spec
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationRestore
metadata:
  name: restore
  namespace: mysql
spec:
  backupName: backup
  backupLocation: greatdane
```

Once you apply the above spec you should be able to check the status of the restore using storkctl
```
$ storkctl get applicationrestore -n mysql
NAME      STAGE     STATUS           VOLUMES   RESOURCES   CREATED               ELAPSED
restore   Final     PartialSuccess   1/1       9           12 Jun 19 05:18 UTC   28s
```

You can also describe the object to get more information about the restore
```
$ kubectl describe applicationrestores.stork.libopenstorage.org -n mysql
Name:         restore
Namespace:    mysql
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"ApplicationRestore","metadata":{"annotations":{},"name":"restore","namespace":"m...
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         ApplicationRestore
Metadata:
  Creation Timestamp:  2019-06-12T05:18:13Z
  Generation:          1
  Resource Version:    60317924
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/mysql/applicationrestores/restore
  UID:                 79c694cb-8cd1-11e9-9c67-0214683e8447
Spec:
  Backup Location:  greatdane
  Backup Name:      backup
  Encryption Key:   <nil>
  Namespace Mapping:
    Mysql:         mysql
  Replace Policy:  Retain
  Selectors:       <nil>
Status:
  Finish Timestamp:  2019-06-12T05:18:41Z
  Resources:
    Group:     
    Kind:       PersistentVolume
    Name:       pvc-79ca45cc-8cd1-11e9-b696-0efbb4d53f15
    Namespace: 
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:     
    Kind:       ServiceAccount
    Name:       mysql-account
    Namespace:  mysql
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:     
    Kind:       Secret
    Name:       mysql-account-token-pwgbq
    Namespace:  mysql
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:     
    Kind:       Secret
    Name:       s3secret
    Namespace:  mysql
    Reason:     Resource restore skipped as it was already present and ReplacePolicy is set to Retain
    Status:     Retained
    Version:    v1
    Group:     
    Kind:       PersistentVolumeClaim
    Name:       mysql-data
    Namespace:  mysql
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:     
    Kind:       Service
    Name:       mysql
    Namespace:  mysql
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:      apps
    Kind:       Deployment
    Name:       mysql
    Namespace:  mysql
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
    Group:      rbac.authorization.k8s.io
    Kind:       ClusterRole
    Name:       mysql-role
    Namespace: 
    Reason:     Resource restore skipped as it was already present and ReplacePolicy is set to Retain
    Status:     Retained
    Version:    v1
    Group:      rbac.authorization.k8s.io
    Kind:       ClusterRoleBinding
    Name:       mysql-role-binding
    Namespace: 
    Reason:     Resource restored successfully
    Status:     Successful
    Version:    v1
  Stage:        Final
  Status:       PartialSuccess
  Volumes:
    Persistent Volume Claim:  mysql-data
    Reason:                   Restore successful for volume
    Restore Volume:           pvc-79ca45cc-8cd1-11e9-b696-0efbb4d53f15
    Source Namespace:         mysql
    Source Volume:            pvc-89dc1ed5-8ccd-11e9-9c67-0214683e8447
    Status:                   Successful
Events:                       <none>
```
If there are any errors you should see events raised in the object.