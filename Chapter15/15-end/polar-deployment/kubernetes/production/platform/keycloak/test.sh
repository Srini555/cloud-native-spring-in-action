#!/bin/sh

export KEYCLOAK_USERNAME=$(kubectl get secret credential-polar-keycloak -o jsonpath='{.data.ADMIN_USERNAME}' --namespace=keycloak-system | base64 --decode)
export KEYCLOAK_PASSWORD=$(kubectl get secret credential-polar-keycloak -o jsonpath='{.data.ADMIN_PASSWORD}' --namespace=keycloak-system | base64 --decode)
export CLIENT_SECRET=$(kubectl get secret keycloak-client-secret-edge-service -o jsonpath='{.data.CLIENT_SECRET}' --namespace=keycloak-system | base64 --decode)

echo "Admin Username: $KEYCLOAK_USERNAME\n"
echo "Admin Password: $KEYCLOAK_PASSWORD\n"
echo "Client Secret: $CLIENT_SECRET\n"
