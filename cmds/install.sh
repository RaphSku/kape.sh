############################
# HELPERS                  #
############################
create_install() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape install <command> [flags]

Commands:
  cilium          Install cilium on kind cluster
  hubble          Enable Hubble on kind cluster
  istio-gateway   Install Istio gateway on kind cluster
  help            Show help for a command

Run 'kape install help <command>' for more details.
EOF
}

############################
# COMMANDS                 #
############################
cmd_install() {
    if [[ $# -eq 0 ]]; then
        create_install; exit 1
    fi

    local cmd="$1"; shift || true

    case "$cmd" in
        cilium) cmd_install_cilium "$@" ;;
        hubble) cmd_enable_hubble "$@" ;;
        istio-gateway) cmd_install_istio_gateway "$@" ;;
        help)
            if [[ $# -eq 0 ]]; then create_install
            else
                case "$1" in
                    cilium) echo "Will install cilium on your kind cluster";;
                    hubble) echo "Enable Hubble on current kind cluster";;
                    istio-gateway) echo "Install Istio gateway";;
                    *) err "[ERROR] - Unknown help topic: $1"; exit 1;;
                esac
            fi ;;
        *)
            err "[ERROR] - Unknown command: $cmd"
            create_install
            exit 1 ;;
    esac
}