#!/bin/sh

echo "🏴‍☠️ Destroying Kubernetes cluster..."

kind delete cluster --name polar-cluster

echo "🏴‍☠️ Cluster destroyed\n"
