#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

LADEFREE_REPO_URL_BASE="https://github.com/byJoey/ladefree"
LADEFREE_REPO_BRANCH="main"
LADE_CLI_NAME="lade"
LADE_INSTALL_PATH="/usr/local/bin/${LADE_CLI_NAME}"

display_welcome() {
    clear
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${CYAN}#${NC}                                                           ${CYAN}#${NC}"
    echo -e "${CYAN}#${NC}        ${BLUE}Welcome to Lade CLI Multi-function Management Script v1.0.0${NC}        ${CYAN}#${NC}"
    echo -e "${CYAN}#${NC}                                                           ${CYAN}#${NC}"
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${GREEN}"
    echo "  >> Author: MrHtunNaung"
    echo -e "${NC}"
    echo -e "${YELLOW}This is an automated Lade application deployment and management tool designed to simplify operations.${NC}"
    echo ""
    read -p "Press Enter to start..."
}

display_section_header() {
    echo ""
    echo -e "${PURPLE}--- ${1} ---${NC}"
    echo -e "${PURPLE}-----------------------------------${NC}"
}

command_exists() {
    command -v "$1" &> /dev/null
}

install_package() {
    local package_name="$1"
    echo -e "${YELLOW}Trying to install missing command: '${package_name}'...${NC}"

    local os_type=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "${os_type}" in
        linux)
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y "${package_name}"
            elif command_exists yum; then
                sudo yum install -y "${package_name}"
            elif command_exists dnf; then
                sudo dnf install -y "${package_name}"
            else
                echo -e "${RED}Error: No supported Linux package manager found (apt-get, yum, dnf). Please install '${package_name}' manually.${NC}"
                return 1
            fi
            ;;
        darwin)
            if command_exists brew; then
                brew install "${package_name}"
            else
                echo -e "${RED}Error: Homebrew not found on macOS. Please install Homebrew (https://brew.sh/) first, then manually install '${package_name}'.${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}Error: OS '${os_type}' not supported for automatic installation. Please install '${package_name}' manually.${NC}"
            return 1
            ;;
    esac

    if ! command_exists "${package_name}"; then
        echo -e "${RED}Error: Automatic installation of '${package_name}' failed. Please install manually and try again.${NC}"
        return 1
    fi
    echo -e "${GREEN}'${package_name}' installed successfully.${NC}"
    return 0
}

check_lade_cli() {
    command_exists "$LADE_CLI_NAME"
}

ensure_lade_login() {
    echo ""
    echo -e "${PURPLE}--- Checking Lade login status ---${NC}"
    if ! lade apps list &> /dev/null; then
        echo -e "${RED}Error: Lade not logged in or login failed. Please run 'lade login' manually to log in.${NC}"
        exit 1
    else
        echo -e "${GREEN}Lade is logged in.${NC}"
    fi
}

deploy_app() {
    display_section_header "Deploying Application"
    # Your deployment commands here
    echo -e "${GREEN}Deployment function placeholder.${NC}"
}

main() {
    display_welcome

    if ! check_lade_cli; then
        echo -e "${YELLOW}Lade CLI not found. Attempting to install...${NC}"
        if ! install_package "$LADE_CLI_NAME"; then
            echo -e "${RED}Failed to install Lade CLI. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Lade CLI found.${NC}"
    fi

    ensure_lade_login

    deploy_app
}

main "$@"
