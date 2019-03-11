#!/usr/bin/env bash

# COMMON VARS
RG_NAME="sathya-px-rg"
REGION="westus"
CLUSTER_NAME="sathya-px-aks"
CLUSTER_SIZE=3
DISK_SIZE_GB=200
DISK_SKU="Standard_LRS"

#az login
#az group create --name ${RG_NAME} --location ${REGION}

# Get latest kubernetes version
K8S_VER=`az aks get-versions --location westus --output table | grep None | awk '{print $1}'`

echo "[INFO]: Deploying AKS cluster ${CLUSTER_NAME}"
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count ${CLUSTER_SIZE} --enable-addons monitoring --generate-ssh-keys --kubernetes-version ${K8S_VER}
echo "[INFO]: backing up current kube-config into \"~/.kube/config.bak\""
mv ~/.kube/config ~/.kube/config.bak
cat /dev/null > ~/.kube/config
echo "[INFO]: Get credentials; update kube-config"
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

# Get all VMs
RG_NAME_UPPER=`echo ${RG_NAME} | tr '[:lower:]' '[:upper:]'`
CLUSTER_NAME_UPPER=`echo ${CLUSTER_NAME} | tr '[:lower:]' '[:upper:]'`
REGION_UPPER=`echo ${REGION} | tr '[:lower:]' '[:upper:]'`

RG_UPPER="MC_${RG_NAME_UPPER}_${CLUSTER_NAME_UPPER}_${REGION_UPPER}
az vm list --resource-group ${RG_UPPER} | jq '.[].name'

# Attach disks
echo "[INFO]: Attaching disks to VMs now..."
for vm in $(az vm list --resource-group ${RG_UPPER} | jq '.[].name' | tr -d "\""); do
    echo "Attaching disk to vm $vm"
    az vm disk attach --resource-group ${RG_UPPER} --vm-name $vm --name px_$vm --size-gb ${DISK_SIZE_GB} --sku ${DISK_SKU} --new
done

# Install PX
echo "[INFO]: Installing PX...@TODO"

# Done
