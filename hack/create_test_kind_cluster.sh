#!/usr/bin/env bash

set -e
set -o pipefail

echo "Checking whether kubectl is installed"
which kubectl || { echo "You have to install kubectl"; exit 1; }

if $(kind get clusters | grep -qx $KIND_CLUSTER_NAME); then
    echo "A kind cluster with the name ${KIND_CLUSTER_NAME} is already running!";
    exit 1;
fi
./kape.sh create kind-cluster --kind-config=$KIND_CONFIG
kubectl cluster-info --context kind-kind-multi-node-cluster

./kape.sh install cilium --version $CILIUM_VERSION
./kape.sh install hubble

kubectl label node $KIND_CLUSTER_NAME-control-plane node.kubernetes.io/exclude-from-external-load-balancers-
kubectl label node $KIND_CLUSTER_NAME-control-plane istio-gateway=ingress

./kape.sh install istio-gateway --istio-config=$ISTIO_CONFIG
kubectl apply -f $ISTIO_GATEWAY_CONFIG

echo "Your kind cluster is ready to use!"
echo "Don't forget to run 'make start_lb_mock' in another terminal session!";