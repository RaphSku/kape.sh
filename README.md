# kape.sh
kape.sh helps you to bootstrap a kind (Kubernetes in Docker) cluster for testing.

## Installation
You can install kape with
```bash
curl -LsSf https://raw.githubusercontent.com/RaphSku/kape.sh/refs/heads/main/install.sh | sh
```

> **Note:**
> The installation script will clone this Git repository into /usr/local/share and symlink it
> into /usr/local/bin/kape.

To update kape, you just have to run
```bash
cd /usr/local/share/kape & git pull
```

## General Notes
I have created kape in order to safe time bootstraping kind clusters for testing. For instance,
I often deploy kind without the default CNI in order to install Cilium and Istio as a service mesh and
to use its Gateway API functionality. So kape is rather tailored to **my needs** but maybe it
is useful to you too!
