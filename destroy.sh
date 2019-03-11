#!/usr/bin/env bash

RG_NAME="sathya-px-rg"

az login
az group delete --name ${RG_NAME} --yes --no-wait
