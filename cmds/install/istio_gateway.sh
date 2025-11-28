############################
# HELPERS                  #
############################
install_istio_gateway_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape install istio-gateway [flags]

Flags:
  --istio-config    Istio configuration to use to install and configure Istio
  --crd-version     Gateway API version for CRDs 
  --help | -h       Show usage help for this command

Run 'kape install istio-gateway <flags> --help' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_install_istio_gateway() {
    check_if_tool_is_installed "yq"
    check_if_tool_is_installed "kubectl"
    check_tool_version "kubectl" $kubectl_version_pinned
    check_if_tool_is_installed "istioctl"
    check_tool_version "istioctl" $istioctl_version_pinned

    local istio_config
    local crd_version="1.4.0"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --istio-config=*)
                istio_config="${1#*=}"
                shift
                ;;
            --istio-config)
                istio_config="$2"
                shift 2
                ;;
            --crd-version=*)
                profile="${1#*=}"
                shift
                ;;
            --crd-version)
                profile="$2"
                shift 2
                ;;
            -h|--help)
                bold "Usage: kape install istio-gateway --istio-config=<istio_config.yaml> [--crd-version=<gateway_api_crd_version>]"
                return
                ;;
            *)
                err "[ERROR] - Unknown flag: $1"
                install_cilium_usage
                return 1
                ;;
        esac
    done

    current_context=$(yq '.current-context' $default_kubeconfig)
    k8s_cluster=$(yq ".contexts[] | select(.name == \"${current_context}\") | .context.cluster" $default_kubeconfig)

    echo "$(bold [INFO]) - Will implement Istio Gateway API for you..."
    echo "$(bold [INFO]) - Let us install the Kubernetes Gateway API CRDs which are required"

    confirm "Enable Istio Gateway on K8s cluster ($k8s_cluster)?" || { echo "$(bold [INFO]) - Confirmation failed, will not enable Istio!"; exit 1; }

    kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
        { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v${crd_version}" | kubectl apply -f -; }

    echo "$(bold [INFO]) - Let us install Istio now"

    [[ -n ${istio_config:-} ]] || { err "[ERROR] - You have to provide --istio-config"; exit 1; }
    istioctl install -f $istio_config -y

    echo "$(bold [INFO]) - Istio is ready to serve your ingress traffic"
}