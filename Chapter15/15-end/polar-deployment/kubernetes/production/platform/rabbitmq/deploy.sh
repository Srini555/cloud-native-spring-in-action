#!/bin/sh

echo "\n"

echo "🐰 RabbitMQ deployment started."

echo "\n-----------------------------------------------------\n"

echo "📦 Installing RabbitMQ Cluster Kubernetes Operator...\n"

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/download/v1.10.0/cluster-operator.yml"

echo "\n"
echo "Waiting for the RabbitMQ Cluster Kubernetes Operator to be ready...\n"

sleep 5

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=rabbitmq-cluster-operator \
  --timeout=300s \
  --namespace=rabbitmq-system

echo "\n"
echo "The RabbitMQ Cluster Kubernetes Operator has been successfully installed.\n"

echo "\n-----------------------------------------------------\n"

echo "📦 Deploying RabbitMQ cluster...\n"

kubectl apply -f resources/namespace.yml
kubectl apply -f resources/cluster.yml

echo "\n"
echo "Waiting for the RabbitMQ cluster to be ready...\n"

sleep 5

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=polar-rabbitmq \
  --timeout=600s \
  --namespace=polar-rabbitmq

echo "\n"
echo "The RabbitMQ cluster has been successfully deployed.\n"

export RABBITMQ_USERNAME=$(kubectl get secret polar-rabbitmq-default-user -o jsonpath='{.data.username}' --namespace=polar-rabbitmq | base64 --decode)
export RABBITMQ_PASSWORD=$(kubectl get secret polar-rabbitmq-default-user -o jsonpath='{.data.password}' --namespace=polar-rabbitmq | base64 --decode)

kubectl create secret generic polar-rabbitmq-secret \
    --from-literal=spring.rabbitmq.username=$RABBITMQ_USERNAME \
    --from-literal=spring.rabbitmq.password=$RABBITMQ_PASSWORD

unset RABBITMQ_USERNAME
unset RABBITMQ_PASSWORD

echo "\n"
echo "A 'polar-rabbitmq-secret' has been created for Spring Boot applications to interact with RabbitMQ.\n"

echo "\n-----------------------------------------------------\n"

echo "🐰 RabbitMQ deployment completed.\n"
