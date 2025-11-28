############################
# HELPERS                  #
############################
create_kind_cluster_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape create kind-cluster <command> [flags]

Flags:
  --kind-config     Path to a kind configuration    
  --help | -h       Show usage help for this command

Run 'kape create kind-cluster <flags> --help' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_create_kind_cluster() {
    check_if_tool_is_installed "yq"
    check_if_tool_is_installed "kind"
    check_tool_version "kind" $kind_version_pinned

    if [[ $# -eq 0 ]]; then
        create_kind_cluster_usage; exit 1
    fi

    local kind_config

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --kind-config=*)
                kind_config="${1#*=}"
                shift
                ;;
            --kind-config)
                kind_config="$2"
                shift 2
                ;;
            -h|--help)
                bold "Usage: kape create kind-cluster --kind-config <path_to_kind_config>"
                return
                ;;
            *)
                err "[ERROR] - Unknown flag: $1"
                create_kind_cluster_usage
                return 1
                ;;
        esac
    done

    kind_cluster_name=$(yq '.name' $kind_config)
    default_cni_disabled=$(yq '.networking.disableDefaultCNI // false' $kind_config)
    number_of_nodes=$(yq '.nodes | length' $kind_config)
	[[ -n $(kind get clusters | grep $kind_cluster_name) ]] && err "[ERROR] - The kind cluster '$kind_cluster_name' is already running" && exit 1
    echo "$(bold [INFO]) - A kind cluster with the name $kind_cluster_name does not exist, let us create one..."
	
    confirm "Create kind cluster with name $kind_cluster_name?" || { echo "$(bold [INFO]) - Confirmation failed, will not create kind cluster!"; exit 1; }
    
    if [[ "$number_of_nodes" -gt 1 ]]; then
        echo "$(bold [INFO]) - If you encounter problems with the multi-node provisioning, consult the following page: https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files"
    fi

    args=""
    if [[ "$default_cni_disabled" == "true" && "$number_of_nodes" -gt 1 ]]; then
        echo "$(bold [INFO]) - Default CNI is disabled and you have multiple nodes, will set --retain to preserve nodes in case problems occur"
        args="${args} --retain"
    fi
    kind create cluster --config $kind_config $args

    echo "$(bold [INFO]) - kind cluster $kind_cluster_name has been created"
}