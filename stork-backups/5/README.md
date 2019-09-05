# Scenario 5: Create ApplicationBackupSchedule and Restore from a backup

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

## Create ApplicationBackupSchedule

### Create a SchedulePolicy
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: SchedulePolicy
metadata:
  name: policy1
policy:
  interval:
    intervalMinutes: 10
    retain: 4
  daily:
    time: "10:14PM"
    retain: 3
  weekly:
    day: "Thursday"
    time: "10:13PM"
    retain: 2
  monthly:
    date: 14
    time: "8:05PM"
    retain: 1
```

### Create the ApplicationBackupSchedule
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationBackupSchedule
metadata:
  name: azureBackup
  namespace: kube-system
spec:
  schedulePolicyName: policy1
  template:
    spec:
      backupLocation: azureBackupLocation
      namespaces:
      - mysql
      reclaimPolicy: Delete
```

## Create ApplicationRestore
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
