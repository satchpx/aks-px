# Taking Cloudsnaps via StorageClass

## Upgrade your current stork deployment to the latest
```
kubectl edit deploy stork -n kube-system
```
search for `image: ` and change image to `openstorage/stork:master`

## Create Schedule Policy
Apply the schedulePolicy below:
```
apiVersion: stork.libopenstorage.org/v1alpha1
kind: SchedulePolicy
metadata:
  name: policy1
policy:
  interval:
    intervalMinutes: 10
  daily:
    time: "10:14PM"
  weekly:
    day: "Thursday"
    time: "10:13PM"
  monthly:
    date: 14
    time: "8:05PM"
```

```
root@node1:~# kubectl apply -f schedPolicy.yaml
schedulepolicy.stork.libopenstorage.org/policy1 created
root@node1:~# kubectl get schedulepolicy
NAME      AGE
policy1   13s
```

## Create a StorageClass
Create and apply the storageClass below:
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: px-with-cs-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   snapshotschedule.stork.libopenstorage.org/default-schedule: |
     schedulePolicyName: policy1
     annotations:
       portworx/snapshot-type: local
   snapshotschedule.stork.libopenstorage.org/weekly-schedule: |
     schedulePolicyName: policy1
     annotations:
       portworx/snapshot-type: cloud
       portworx/cloud-cred-id: <credential-uuid>
```
Note that the above credential UUID can be obtained from `pxctl cred list`. This should be the credentials required to authenticate/ access the objectstore. For more information, refer to: https://docs.portworx.com/reference/cli/credentials/


Create the storage class:
```
root@node1:~#  kubectl  apply -f cssc.yaml
storageclass.storage.k8s.io/px-with-cs-sc created
root@node1:~#
root@node1:~# kubectl get sc
NAME                       PROVISIONER                     AGE
px-with-cs-sc              kubernetes.io/portworx-volume   5s
stork-snapshot-sc          stork-snapshot                  22d
```


## Create PVC
Create a PVC that uses the storageClass created above:
```
ind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvcsc-cs-001
  annotations:
    volume.beta.kubernetes.io/storage-class: px-with-cs-sc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

```
root@node1:~# kubectl create -f cspvc.yaml
persistentvolumeclaim/pvcsc-cs-001 created
root@node1:~#
root@node1:~#
root@node1:~#
root@node1:~# kubectl get pvc
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
pvcsc-cs-001   Bound    pvc-128b7724-5030-11e9-8a56-000c2933610a   2Gi        RWO            px-with-cs-sc              5s
root@node1:~#
```
## Check Cloudsnaps
