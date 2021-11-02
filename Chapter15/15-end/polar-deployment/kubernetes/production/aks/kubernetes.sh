#!/bin/sh

az login

export RESOURCE_GROUP=polar-bookshop-group
az group create --name $RESOURCE_GROUP --location northeurope

export AKS_CLUSTER_NAME=polar-cluster
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --node-count 2 \
    --generate-ssh-keys \
    --enable-addons http_application_routing

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME

az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName \
    -o table

5eee3fe9ef58482ea07d.northeurope.aksapp.io

kubectl get nodes

export POSTGRES_SERVER=polar-postgres && \
    export POSTGRES_ADMIN_USERNAME=polaradmin && \
    export POSTGRES_ADMIN_PASSWORD=polarPassw0rd!

az postgres server create \
    --resource-group $RESOURCE_GROUP \
    --name $POSTGRES_SERVER \
    --location northeurope \
    --admin-user $POSTGRES_ADMIN_USERNAME \
    --admin-password $POSTGRES_ADMIN_PASSWORD \
    --public-network-access Disabled \
    --ssl-enforcement Disabled \
    --sku-name GP_Gen5_2 \
    --version 11

az postgres server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server-name $POSTGRES_SERVER \
    --name "AllowAllWindowsAzureIps" \
    --start-ip-address "0.0.0.0" \
    --end-ip-address "0.0.0.0"

az postgres db create --resource-group $RESOURCE_GROUP --server-name $POSTGRES_SERVER --name polardb_catalog
az postgres db create --resource-group $RESOURCE_GROUP --server-name $POSTGRES_SERVER --name polardb_order
az postgres db create --resource-group $RESOURCE_GROUP --server-name $POSTGRES_SERVER --name polardb_keycloak

export REDIS_SERVER=polar-redis

az redis create \
    --resource-group $RESOURCE_GROUP \
    --name $REDIS_SERVER \
    --location northeurope \
    --sku Basic \
    --vm-size c0 
