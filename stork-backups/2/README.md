# Scenario 2: Backup all Namespaces and restore it in a different Cluster

## Create BackupLocation
* Note: The specs need to be created in `kube-system` namespace, as it is by default, the admin-namespace. If you wish to disgnate another namespace as the admin-namespace, run the steps below:
```
kubectl -n kube-system edit deploy stork

# Add the admin-namespace in the container arg, as shown below:
      - command:
        - /stork
        - --driver=pxd
        - --verbose
        - --leader-elect=true
        - --admin-namespace=<admin-namespace>
```

Apply the spec:
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: azureBackupLocation
  namespace: kube-system
  annotations:
    stork.libopenstorage.ord/skipresource: "true"
location:
  type: azure
  path: "stork-test"
  azureConfig:
    storageAccountName: "<redacted>"
    storageAccountKey: "<redacted>"
```

## Create ApplicationBackup
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationBackup
metadata:
  name: azureBackup
  namespace: kube-system
spec:
  backupLocation: azureBackupLocation
  # namespaces to be backed up
  namespaces:
  - mysql
  - kafka
  - monitoring
  - logging
  - spark
  # What to do with the data in the objectstore when the backup object in k8s is deleted. Valid options are Delete and Retain
  reclaimPolicy: Delete
  # List of label selectors to choose specific objects and volumes to backup
  selectors:
  # Rule to run before triggering the backup
  preExecRule:
  # Rule to run after the backup has been triggered
  postExecRule:
```

## Create ApplicationRestore (In the destination cluster)

### 1. Create the BackupLocation object
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: azureBackupLocation
  namespace: kube-system
  annotations:
    stork.libopenstorage.ord/skipresource: "true"
location:
  type: azure
  path: "stork-test"
  sync: true
  azureConfig:
    storageAccountName: "<redacted>"
    storageAccountKey: "<redacted>"
```

### 2. Get the synced object and get the ApplicationBackup object name
```
kubectl -n kube-system get applicationbackup
```

### 3. Create the Restore Object
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationRestore
metadata:
  name: azureRestore
  namespace: kube-system
spec:
  backupName: azureBackup-2019-09-04-213455
  backupLocation: azureBackupLocation
```

### 4. Verify
```
# Use commands below to verify
kubectl -n kube-system get applicationrestore
storkctl -n kube-system get applicationrestore azureRestore
kubectl -n kube-system describe applicationrestore azureRestore
```
