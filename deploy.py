#!/usr/bin/env python3
import argparse
import yaml
import os
import sys
import logging
import datetime
import json
import requests

logger = logging.getLogger('aks')
hdlr = logging.FileHandler('/var/log/aks.log', 'w+')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.INFO)

# AKS API VERSION
api_version="2018-03-31"
supported_regions = [
    'eastus',
    'westeurope',
    'centralus',
    'canadaeast',
    'canadacentral',
    'uksouth',
    'ukwest',
    'westus',
    'westus2',
    'australiaeast',
    'northeurope',
    'japaneast',
    'eastus2',
    'southeastasia'
]

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--subsriptionid', help='ID of the target subscription')
    parser.add_argument('--resourcegroup', help='Name of the resource group for the managed resource')
    parser.add_argument('--region', help='Region to deploy the AKS cluster in')
    parser.add_argument('--clustername', help='Name of the managed AKS cluster')
    parser.add_argument('--clustersize', type=int, help='Size of the cluster (optional) [Default: 3]', default=3)
    parser.add_argument('--disksize', type=int, help='PX disk size in GiB (optional) [Default: 200]', default=200)
    parser.add_argument('--disktype', type=string, help='Disk type or Disk SKU (optional) [Default=Standard_LRS] [Supported Types: StandardSSD_LRS, Standard_LRS, UltraSSD_LRS]', default='Standard_LRS')
    return parser.parse_args()


def create_resource_group(subsriptionid, resourcegroup, region):
    global api_version
    body = {"location": region}
    body_json = json.dumps(body)
    uri = 'https://management.azure.com/subscriptions/' + subscriptionid + '/resourcegroups/' + resourcegroup + '?api-version=' + api_version
    resp = requests.post(uri, data=json.dumps(body), headers={'Content-Type':'application/json'})
    if resp.status_code is not 200:
        logger.error("Failed to create resource group")
        sys.exit(1)
    response = resp.json()
    if response.properties.provisioningState is "Succeeded":
        logger.info("Created resource group " + resourcegroup)
    else:
        logger.error("Resource group provisioning state: " + response.properties.provisioningState)
    return


def get_k8s_version():
    return


def create_cluster():
    return


def get_cluster_credentials():
    return


def add_px_disks():
    return


def install_portworx():
    return


def main():
    global supported_regions
    args = parse_args()
    if args.subsriptionid and args.resourcegroup and args.region and args.clustername:
        subscriptionid = args.subsriptionid
        resource_group = args.resourcegroup
        region = args.region
        clustername = args.clustername
    else:
        print("[ERROR]: Required argument(s) missing")
        sys.exit(1)

    if region not in supported_regions:
        logger.error('Invalid region passed in!')
        sys.exit(1)

    logger.info("Creating resource group: " + resource_group)
    create_resource_group(subscriptionid, resource_group, region)

    k8s_version = get_k8s_version()
    logger.info("Deploying latest available kubernetes version on AKS: " + k8k8s_version)

    logger.info("Creating AKS cluster now...")
    create_cluster()

    logger.info("Getting kubeconfig for deployed AKS cluster")
    get_cluster_credentials()

    logger.info("Adding disks for PX")
    add_px_disks()

    logger.info("Installing portworx")
    install_portworx()


if __name__ == '__main__':
    main()
