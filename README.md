# aks-px
PX on AKS

## To standup a cluster
```
Usage:
    up.sh
      -g <Resource Group Name to create>
      -r <Region> [westus|eastus]
      -c <AKS Cluster Name>
      -n <Cluster Size> [Optional, Default=3]
      -s <PX Disk Size in GiB> [Optional, Default=200]
      -d <Disk Type> [Optional, Default=Standard_LRS] [Supported Types: StandardSSD_LRS, Standard_LRS, UltraSSD_LRS]

Example:
    up.sh -g sathya-px-rg -r westus -c sathya-px-aks -n 3 -s 200 -d Standard_LRS"
```

## To destroy a cluster
```
Usage:
    destroy.sh
    -g <Resource Group Name to destroy>

Example:
    destroy.sh -g sathya-px-rg
```

## To use REST API to deploy the cluster

First install pre-requisites
```
1. Install python3: https://realpython.com/installing-python/
2. Install pip https://pip.pypa.io/en/stable/installing/
3. pip install -r requirements.txt
```

Execute
```
Usage:
    deploy.py

```
