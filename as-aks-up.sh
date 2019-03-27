#!/usr/bin/env bash

printUsage() {
    cat <<EOUSAGE
Usage:
    up.sh
      -g <Resource Group Name to create>
      -r <Region> [westus|eastus]
      -c <AKS Cluster Name>
      -n <Cluster Size> [Optional, Default=3]
      -s <PX Disk Size in GiB> [Optional, Default=200]
      -d <Disk Type> [Optional, Default=Standard_LRS] [Supported Types: StandardSSD_LRS, Standard_LRS, UltraSSD_LRS]

EOUSAGE
    echo "Example: up.sh -g sathya-px-rg -r westus -c sathya-px-aks -n 3 -s 200 -d Standard_LRS"
}

# COMMON VARS
CLUSTER_SIZE=3
DISK_SIZE_GB=200
DISK_SKU="Standard_LRS"
while getopts "h?:g:r:c:n:s:d:" opt; do
    case "$opt" in
    h|\?)
        printUsage
        exit 0
        ;;
    g)  RG_NAME=$OPTARG
        ;;
    r)  REGION=$OPTARG
        ;;
    c)  CLUSTER_NAME=$OPTARG
        ;;
    n)  CLUSTER_SIZE=$OPTARG
        ;;
    s)  DISK_SIZE_GB=$OPTARG
        ;;
    d)  DISK_SKU=$OPTARG
        ;;
    :)
        echo "[ERROR] Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    default)
       printUsage
       exit 1
    esac
done

# Validate Input Args
if [[ (-z ${RG_NAME}) || (-z ${REGION}) || (-z ${CLUSTER_NAME}) ]]; then
    echo "[ERROR]: Required arguments missing"
    printUsage
    exit 1
fi

if [[ (${DISK_SKU} != "Standard_LRS") && (${DISK_SKU} != "StandardSSD_LRS") && (${DISK_SKU} != "UltraSSD_LRS") ]]; then
    echo "[ERROR]: Invalid Disk type"
    printUsage
    exit 1
fi

# @TODO: make login non-interactive
az login
az group create --name ${RG_NAME} --location ${REGION}

# Get latest kubernetes version
K8S_VER=`az aks get-versions --location westus --output table | grep None | awk '{print $1}'`

# Set cluster max size
CLUSTER_SIZE_MAX=$((CLUSTER_SIZE*2))
echo "[INFO]: Deploying AKS cluster ${CLUSTER_NAME}"
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count ${CLUSTER_SIZE} --enable-vmss --enable-cluster-autoscaler --min-count ${CLUSTER_SIZE} --max-count ${CLUSTER_SIZE_MAX} --enable-addons monitoring --generate-ssh-keys --kubernetes-version ${K8S_VER}
echo "[INFO]: backing up current kube-config into \"~/.kube/config.bak\""
mv ~/.kube/config ~/.kube/config.bak
cat /dev/null > ~/.kube/config
echo "[INFO]: Get credentials; update kube-config"
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

# Get all VMs
RG_NAME_UPPER=`echo ${RG_NAME} | tr '[:lower:]' '[:upper:]'`
CLUSTER_NAME_UPPER=`echo ${CLUSTER_NAME} | tr '[:lower:]' '[:upper:]'`
REGION_UPPER=`echo ${REGION} | tr '[:lower:]' '[:upper:]'`

#RG_UPPER="MC_${RG_NAME_UPPER}_${CLUSTER_NAME_UPPER}_${REGION_UPPER}"
RG_UPPER="MC_${RG_NAME}_${CLUSTER_NAME}_${REGION}"
az vm list --resource-group ${RG_UPPER} | jq '.[].name'

echo "[INFO]: Finished deploying AKS cluster with VMSS and autoscaler enabled."
echo "[INFO]: Skipping adding drives and installing PX..."
echo "[INFO]: Please install portworx with cloud-drive-management. Refer to https://github.com/satchpx/aks-px/tree/master/cloud-drive-management"
