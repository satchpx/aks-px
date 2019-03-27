# AKS cluster with PX and cloud drive management

## Deploy the cluster
```
git clone https://github.com/satchpx/aks-px.git
cd aks-px
./up.sh
```

## Create and register an "APP" with azure AD to use Azure APIs
References:

https://blog.tekspace.io/accessing-azure-rest-api/
https://docs.microsoft.com/en-us/rest/api/azure/#register-your-client-application-with-azure-ad
https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v1-add-azure-ad-app

## Get the following before proceeding to the next step
```
AZURE_TENANT_ID: Azure AD account
AZURE_CLIENT_ID: Application ID of the app created in the step above
AZURE_CLIENT_SECRET: Password created for the app in the step above
```

## Install PX
`@TODO: Add support in the spec generator. But for now, follow the steps below:`
1. Generate the spec from install.portworx.com
2. Instead of `auto` for storage, replace it with the cloud-drive spec, similar to `"-s", "type=Premium_LRS,size=100"`
3. Specify `PX_IMAGE` in oci-monitor environment
```
- name: "PX_IMAGE"
  value: "satchpx/px-enterprise:2.1.0-test"
```
4. Specify the necessary parameters to talk to Azure APIs
```
- name: "AZURE_TENANT_ID"
  value: "<Azure tenant ID>"
- name: "AZURE_CLIENT_SECRET"
  value: "<Azure client secret>"
- name: "AZURE_CLIENT_ID"
  value: "<Azure client ID>"
```
`@TODO: Note that steps 2,3,4 above should be obsoleted once the GA `px-enterprise` image is released with support for cloud-drive management on AWS, and once spec-generator is updated to take in the required parameters for using Azure APIs.`

## Enable autoscaler on AKS cluster
Currently enabling autoscaler on a running AKS cluster does not work. This requires:
1. Installing AKS cluster with `Virtual Machine Scale Sets` enabled
2. Install `aks-preview` extension.

References:
https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler
https://github.com/MicrosoftDocs/azure-docs/issues/24942

Here's an example command to deploy an AKS cluster with Virtual Machine scale sets enabled and autoscaler enabled:
```
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count ${CLUSTER_SIZE} --enable-vmss --enable-cluster-autoscaler --min-count ${CLUSTER_SIZE} --max-count ${CLUSTER_SIZE_MAX} --enable-addons monitoring --generate-ssh-keys --kubernetes-version ${K8S_VER}
```

To install portworx on this cluster, follow the procedure from above


## Advanced:
### Deploy multi-zone AKS cluster

### Deploy multi-zone AKS cluster with autoscaler
