############################
# HELPERS                  #
############################
create_usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape create <command> [flags]

Commands:
  kind-cluster  Create kind cluster
  help          Show help for a command

Run 'kape create help <command>' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_create() {
    if [[ $# -eq 0 ]]; then
        create_usage; exit 1
    fi

    local cmd="$1"; shift || true

    case "$cmd" in
        kind-cluster) cmd_create_kind_cluster "$@" ;;
        help)
            if [[ $# -eq 0 ]]; then create_usage
            else
                case "$1" in
                    kind-cluster) echo "Can create kind cluster";;
                    *) err "[ERROR] - Unknown help topic: $1"; exit 1;;
                esac
            fi ;;
        *)
            err "[ERROR] - Unknown command: $cmd"
            create_usage
            exit 1 ;;
    esac
}