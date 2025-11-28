############################
# HELPERS                  #
############################
install_cilium_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape install cilium [flags]

Flags:
  --version         cilium version to install
  --run-tests       Whether cilium's connectivity tests should be run
  --help | -h       Show usage help for this command

Run 'kape install cilium <flags> --help' for more details.
EOF
}

install_hubble_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape install hubble [flags]

Flags:    
  --help | -h       Show usage help for this command

Run 'kape install hubble <flags> --help' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_install_cilium() {
    check_if_tool_is_installed "yq"
    check_if_tool_is_installed "cilium"
    check_tool_version "cilium" $cilium_version_pinned

    local version=""
    local run_tests="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --run-tests)
                run_tests="$1"
                shift
                ;;
            -h|--help)
                bold "Usage: kape install cilium [--version=<cilium_version>] [--run-tests]"
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
    if [[ -n $version ]]; then
        echo "$(bold [INFO]) - You have specified the version $version"
    else
        echo "$(bold [INFO]) - You did not specify a version, will proceed with default version"
    fi
    confirm "Install cilium on K8s cluster ($k8s_cluster)?" || { echo "$(bold [INFO]) - Confirmation failed, will not install cilium!"; exit 1; }

    echo "$(bold [INFO]) - Installing cilium on the following K8s cluster: $k8s_cluster"
    if [[ -n $version ]]; then
        cilium install --version $version
    else
        cilium install
    fi
    cilium status --wait

    if [[ "$run_tests" == "true" ]]; then
        cilium connectivity test
    fi
    echo "$(bold [INFO]) - Successfully installed cilium"
}

cmd_enable_hubble() {
    check_if_tool_is_installed "yq"
    check_if_tool_is_installed "cilium"
    check_tool_version "cilium" $cilium_version_pinned

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                bold "Usage: kape install hubble"
                return
                ;;
            *)
                err "[ERROR] - Unknown flag: $1"
                install_hubble_usage
                return 1
                ;;
        esac
    done

    current_context=$(yq '.current-context' $default_kubeconfig)
    k8s_cluster=$(yq ".contexts[] | select(.name == \"${current_context}\") | .context.cluster" $default_kubeconfig)
    confirm "Enable Hubble on K8s cluster ($k8s_cluster)?" || { echo "$(bold [INFO]) - Confirmation failed, will not enable hubble!"; exit 1; }

    echo "$(bold [INFO]) - Enabling Hubble now..."
    cilium hubble enable --ui
    echo "$(bold [INFO]) - Successfully enabled Hubble"
}