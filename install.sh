#!/usr/bin/env bash

set -e

APP_NAME="kape"
REPO_OWNER="RaphSku"
REPO_NAME="kape.sh"
INSTALL_DIR="/usr/local/share/${APP_NAME}"
BIN_DIR="/usr/local/bin"

# --- Helper functions ---
echo_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
echo_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# --- Check for root privileges if installing system-wide ---
if [[ $EUID -ne 0 ]]; then
    echo_error "This installer must be run as root (try sudo)."
    exit 1
fi

echo_info "Installing $APP_NAME..."

# --- Create install directory ---
if [[ -d "$INSTALL_DIR" ]]; then
    echo_error "You already have installed ${APP_NAME}"
    exit 1
fi
echo_info "Creating directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# --- Clone Repository & Symlink script ---
echo_info "Cloning ${APP_NAME} Git repository to ${INSTALL_DIR}"
git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "$INSTALL_DIR"
ln -sf "${INSTALL_DIR}/${REPO_NAME}" "${BIN_DIR}/${APP_NAME}"
chmod +x "${BIN_DIR}/${APP_NAME}"

echo_info "Successfully installed $APP_NAME! Have Fun!"
echo_info "Ensure that ${BIN_DIR} is on PATH, e.g. echo \"export PATH=${BIN_DIR}:\$PATH\" >> ~/.bashrc"