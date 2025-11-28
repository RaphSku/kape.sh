SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

KIND_CONFIG:=./examples/multi-node-cluster-without-cni-config.yaml
KIND_CLUSTER_NAME:=$(shell yq '.name' $(KIND_CONFIG))

CILIUM_VERSION:=1.18.4

ISTIO_CONFIG:=./examples/istio-operator.yaml
ISTIO_GATEWAY_CONFIG:=./examples/istio-gateway-resources.yaml

CLOUD_PROVIDER_KIND=cloud-provider-kind

default: help

.PHONY: start_lb_mock
## Start Cloud Provider Kind to mock load balancer functionality
start_lb_mock:
	@echo "Checking whether $(CLOUD_PROVIDER_KIND) is installed"
	@which $(CLOUD_PROVIDER_KIND) || { echo "You have to install $(CLOUD_PROVIDER_KIND)"; exit 1; }
	$(CLOUD_PROVIDER_KIND)

.PHONY: create_test_kind_cluster
## Create test kind cluster
create_test_kind_cluster:
	@KIND_CLUSTER_NAME=$(KIND_CLUSTER_NAME) \
	KIND_CONFIG=$(KIND_CONFIG) \
	CILIUM_VERSION=$(CILIUM_VERSION) \
	ISTIO_CONFIG=$(ISTIO_CONFIG) \
	ISTIO_GATEWAY_CONFIG=$(ISTIO_GATEWAY_CONFIG) \
	./hack/create_test_kind_cluster.sh

.PHONY: delete_kind_cluster
## Delete an existing kind cluster
delete_kind_cluster:
	./kape.sh delete kind-cluster --kind-config=$(KIND_CONFIG)

.PHONY: help
## Print this help screen
help:
	@echo "----------------------------------"
	@echo "Welcome to make! Enjoy the flight."
	@echo "Makefile - make [\033[38;5;154mtarget\033[0m]"
	@echo "----------------------------------"
	@echo
	@echo "Targets:"
	@awk '/^[a-zA-z\-_0-9%:\\]+/ { \
		description = match(descriptionLine, /^## (.*)/); \
		if (description) { \
			target = $$1; \
			description = substr(descriptionLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", target); \
			gsub(":+$$", "", target); \
			printf "    \033[38;5;154m%-35s\033[0m %s\n", target, description; \
		} \
	} \
	{ descriptionLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"