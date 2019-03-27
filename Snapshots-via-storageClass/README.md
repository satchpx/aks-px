# Taking Cloudsnaps via StorageClass

## Upgrade your current stork deployment to the latest
```
kubectl edit deploy stork -n kube-system
```
search for `image: ` and change image to `openstorage/stork:master`

## Update stork-role permissions
```
kubectl edit clusterrole stork-role -n kube-system
```
Search for `migrations` and add the additional permissions. The section should look like:
```
- apiGroups:
  - stork.libopenstorage.org
  resources:
  - migrations
  - clusterpairs
  - groupvolumesnapshots
  - storageclusters
  - schedulepolicies
  - migrationschedules
  - volumesnapshotschedules
  verbs:
  - get
  - list
  - watch
  - update
  - patch
  - create
  - delete
  ```


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
We can use different means to verify that the snapshots were created:
```kubectl get volumesnapshots
NAME                                                       AGE
pvcsc-cs-001-default-schedule-interval-2019-03-27-015546   2m
pvcsc-cs-001-weekly-schedule-interval-2019-03-27-015546    2m
root@node1:~# pxctl cs list
SOURCEVOLUME						SOURCEVOLUMEID			CLOUD-SNAP-ID								CREATED-TIME				TYPE		STATUS
pvc-128b7724-5030-11e9-8a56-000c2933610a		35471192544934465		071c0f65-e596-41b7-a944-5818b3dae1c3/35471192544934465-302693491218158770		Wed, 27 Mar 2019 01:55:47 UTC		Manual		Done
root@node1:~# pxctl v l -s -p pvc-128b7724-5030-11e9-8a56-000c2933610a
ID			NAME											SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
302693491218158770	pvc-128b7724-5030-11e9-8a56-000c2933610a_35471192544934465_clmanual_2019-03-27T01-55-46	2 GiB	2	no	no		LOW	up - detached	no
790045360885055977	snapshot-7012f4a0-5033-11e9-8a56-000c2933610a						2 GiB	2	no	no		LOW	up - detached	no
root@node1:~# storkctl get volumesnapshots
NAME                                                       PVC            STATUS    CREATED               COMPLETED             TYPE
pvcsc-cs-001-default-schedule-interval-2019-03-27-015546   pvcsc-cs-001   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   local
pvcsc-cs-001-weekly-schedule-interval-2019-03-27-015546    pvcsc-cs-001   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   cloud
```
