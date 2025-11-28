############################
# HELPERS                  #
############################
delete_kind_cluster_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape delete kind-cluster <command> [flags]

Flags:
  --kind-config     Path to a kind configuration    
  --help | -h       Show usage help for this command

Run 'kape delete kind-cluster <flags> --help' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_delete_kind_cluster() {
    check_if_tool_is_installed "yq"
    check_if_tool_is_installed "kind"
    check_tool_version "kind" $kind_version_pinned

    if [[ $# -eq 0 ]]; then
        delete_kind_cluster_usage; exit 1
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
                bold "Usage: kape delete kind-cluster --kind-config <path_to_kind_config>"
                return
                ;;
            *)
                err "[ERROR] - Unknown flag: $1"
                delete_kind_cluster_usage
                return 1
                ;;
        esac
    done

    kind_cluster_name=$(yq '.name' $kind_config)
	[[ -z $(kind get clusters | grep $kind_cluster_name) ]] && err "[ERROR] - The kind cluster '$kind_cluster_name' does not exist" && exit 1
    echo "$(bold [INFO]) - A kind cluster with the name $kind_cluster_name exists, let us delete it..."

    confirm "Delete kind cluster with name $kind_cluster_name?" || { echo "$(bold [INFO]) - Confirmation failed, will not delete kind cluster!"; exit 1; }

    kind delete cluster --name $kind_cluster_name

    echo "$(bold [INFO]) - kind cluster $kind_cluster_name has been deleted"
}