# Using Stork to perform backups

## Pre-requisites

### 1. Update stork

### 2. Update Portworx

### 3. Update stork-role permissions


## Below are the scenarios we'll run through (Refer to the appropriate directory)
```
1. Create ApplicationBackup -> delete apps in that namespace -> create ApplicationRestore
2. Create ApplicationBackup to backup all namespaces in a cluster -> Restore it in a different cluster
3. Create ApplicationBackup of a namespace -> Restore it in another namespace
4. Create ApplicationBackup of a namespace in one cluster -> Restore it to another cluster
5. Test ApplicationBackupSchedule -> Restore a single namespace
```