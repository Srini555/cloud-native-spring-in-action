#!/bin/sh

echo "⛵ Initializing Kubernetes cluster...\n"

kind create cluster --config kind-config.yml

echo "\n-----------------------------------------------------\n"

echo "🔌 Installing NGINX Ingress...\n"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "\n"
echo "⌛ Waiting for NGINX Ingress to be ready...\n"

sleep 10

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "\n"
echo "⛵ Happy Sailing!\n"
