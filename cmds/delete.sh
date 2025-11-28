############################
# HELPERS                  #
############################
delete_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape delete <command> [flags]

Commands:
  kind-cluster  Delete kind cluster
  help          Show help for a command

Run 'kape delete help <command>' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_delete() {
    if [[ $# -eq 0 ]]; then
        delete_usage; exit 1
    fi

    local cmd="$1"; shift || true

    case "$cmd" in
        kind-cluster) cmd_delete_kind_cluster "$@" ;;
        help)
            if [[ $# -eq 0 ]]; then delete_usage
            else
                case "$1" in
                    kind-cluster) echo "Can delete kind cluster";;
                    *) err "[ERROR] - Unknown help topic: $1"; exit 1;;
                esac
            fi ;;
        *)
            err "[ERROR] - Unknown command: $cmd"
            delete_usage
            exit 1 ;;
    esac
}