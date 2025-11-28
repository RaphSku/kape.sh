#!/usr/bin/env bash
set -e
set -u
set -o pipefail

############################
# METADATA                 #
############################
VERSION="0.1.0"

############################
# REQUIRED VERSIONS        #
############################
kubectl_version_pinned="1.32.7"
kind_version_pinned="0.30.0"
cilium_version_pinned="0.18.8"
istioctl_version_pinned="1.28.0"

############################
# TEXT HIGHLIGHTING        #
############################
bold() { echo -e "\033[1m$*\033[0m"; }
err()  { echo -e "\033[31m$*\033[0m" >&2; }

############################
# HELPERS                  #
############################
usage() {
    cat <<EOF
$(bold "kape") – configure kind clusters the easy way for testing!

Usage:
  kape <command> [flags]

Commands:
  create     Create kind resources
  delete     Delete kind resources
  install    Install kind resources
  version    Show version
  help       Show help for a command

Run 'kape help <command>' for more details.
EOF
}

############################
# TOOL CHECK HELPERS       #
############################
check_if_tool_is_installed() {
    [[ -z $(which $1) ]] && err "[ERROR] - You have to install $1 first" && exit 1
    echo "$(bold [INFO]) - $1 is installed"
}

check_tool_version() {
    current_version=$(get_binary_version "$1")
    version_equal "$current_version" "$2" || { echo "$1 version must be v$2!"; exit 1; }
    echo "$(bold [INFO]) - your $1 version v$current_version is OK, required version is v$2"
}

get_binary_version() {
    local bin="$1"
    local output

    output="$("$bin" --version 2>/dev/null)" || \
    output="$("$bin" version 2>/dev/null)"

    echo "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

version_equal() { # returns true if $1 == $2
    local a=$1 b=$2
    [[ "$(printf '%s\n' "$a" "$b" | sort -V | head -n1)" == "$b" ]] && \
    [[ "$(printf '%s\n' "$a" "$b" | sort -V | tail -n1)" == "$b" ]]
}

confirm() {
    while true; do
        read -r -p "${1:-Are you sure?} [y/N] " reply

        case "$reply" in
            [Yy])
                return 0 ;;
            ""|[Nn])
                return 1 ;;
            *)
                echo "Please answer Y or N."
                ;;
        esac
    done
}

default_kubeconfig="$HOME/.kube/config"

############################
# SUBCOMMANDS              #
############################
DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
source "$DIR/cmds/version.sh"

source "$DIR/cmds/create.sh"
source "$DIR/cmds/create/kind-cluster.sh"

source "$DIR/cmds/delete.sh"
source "$DIR/cmds/delete/kind-cluster.sh"

source "$DIR/cmds/install.sh"
source "$DIR/cmds/install/cilium.sh"
source "$DIR/cmds/install/istio_gateway.sh"

############################
# MAIN                     #
############################
main() {
    if [[ $# -lt 1 ]]; then
        usage; exit 1
    fi

    local cmd="$1"; shift || true

    case "$cmd" in
        create) cmd_create "$@" ;;
        delete) cmd_delete "$@" ;;
        install) cmd_install "$@" ;;
        version) cmd_version ;;
        help)
            if [[ $# -eq 0 ]]; then usage
            else
                case "$1" in
                    create) echo "Can create kind related resources, e.g. a kind cluster";;
                    delete) echo "Can delete kind related resources, e.g. a kind cluster";;
                    install) echo "Install kind related resources, e.g. cilium";;
                    version) echo "Shows the version";;
                    *) err "[ERROR] - Unknown help topic: $1"; exit 1;;
                esac
            fi ;;
        *)
            err "[ERROR] - Unknown command: $cmd"
            usage
            exit 1 ;;
    esac
}

main "$@"