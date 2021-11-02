#!/bin/sh

echo "\n"

echo "🗝️ Keycloak deployment started."

echo "\n-----------------------------------------------------\n"

echo "📦 Installing Keycloak Kubernetes Operator...\n"

kubectl apply -f resources/namespace.yml

kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/crds/keycloak.org_keycloakbackups_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/crds/keycloak.org_keycloakclients_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/crds/keycloak.org_keycloakrealms_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/crds/keycloak.org_keycloaks_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/crds/keycloak.org_keycloakusers_crd.yaml

kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/role.yaml --namespace=keycloak-system
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/role_binding.yaml --namespace=keycloak-system
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/service_account.yaml --namespace=keycloak-system

kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-operator/15.0.1/deploy/operator.yaml --namespace=keycloak-system

echo "\n"
echo "Waiting for the Keycloak Kubernetes Operator to be ready...\n"

sleep 60

kubectl wait \
  --for=condition=ready pod \
  --selector=name=keycloak-operator \
  --timeout=300s \
  --namespace=keycloak-system

echo "\n"
echo "The Keycloak Kubernetes Operator has been successfully installed.\n"

echo "\n-----------------------------------------------------\n"

echo "📦 Deploying Keycloak cluster...\n"

kubectl apply -f resources/keycloak-db-secret.yml
kubectl apply -f resources/keycloak.yml

echo "\n"
echo "Waiting for the Keycloak cluster to be ready...\n"

sleep 120

kubectl wait \
  --for=condition=ready pod \
  --selector=component=keycloak \
  --timeout=600s \
  --namespace=keycloak-system

echo "\n"
echo "The Keycloak cluster has been successfully deployed.\n"

echo "\n-----------------------------------------------------\n"

echo "🏰 Configuring Keycloak realm...\n"

kubectl apply -f resources/realm.yml

sleep 5

echo "\n"
echo "👤 Configuring Keycloak users...\n"

kubectl apply -f resources/isabelle.yml
kubectl apply -f resources/bjorn.yml

sleep 5

echo "\n"
echo "🚪 Configuring OAuth2 client...\n"

kubectl apply -f resources/client.yml

sleep 5

echo "\n"
echo "The Keycloak configuration has been successfully completed.\n"

echo "\n-----------------------------------------------------\n"

echo "🔐 Your Keycloak Admin credentials...\n"

export KEYCLOAK_USERNAME=$(kubectl get secret credential-polar-keycloak -o jsonpath='{.data.ADMIN_USERNAME}' --namespace=keycloak-system | base64 --decode)
export KEYCLOAK_PASSWORD=$(kubectl get secret credential-polar-keycloak -o jsonpath='{.data.ADMIN_PASSWORD}' --namespace=keycloak-system | base64 --decode)
export CLIENT_SECRET=$(kubectl get secret keycloak-client-secret-edge-service -o jsonpath='{.data.CLIENT_SECRET}' --namespace=keycloak-system | base64 --decode)

echo "Admin Username: $KEYCLOAK_USERNAME\n"
echo "Admin Password: $KEYCLOAK_PASSWORD\n"

kubectl create secret generic polar-keycloak-client-secret \
    --from-literal=spring.security.oauth2.client.registration.keycloak.client-secret=$CLIENT_SECRET

unset KEYCLOAK_USERNAME
unset KEYCLOAK_PASSWORD
unset CLIENT_SECRET

echo "\n"
echo "A 'polar-keycloak-client-secret' has been created for Spring Boot applications to interact with Keycloak.\n"

echo "\n-----------------------------------------------------\n"

echo "🗝️ Keycloak deployment completed.\n"
