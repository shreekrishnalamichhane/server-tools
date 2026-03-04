#!/bin/bash

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}    Server Tools - Main Menu${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Main menu loop
while true; do
    show_header
    echo -e "${GREEN}Available Categories:${NC}"
    echo ""
    echo "  1. System Resources"
    echo "  2. Docker Tools"
    echo ""
    echo -e "${YELLOW}  0. Exit${NC}"
    echo ""
    echo -e -n "${BLUE}Select a category: ${NC}"
    read -r choice

    case $choice in
        1)
            bash "$(dirname "$0")/resources/menu.sh"
            ;;
        2)
            bash "$(dirname "$0")/docker/menu.sh"
            ;;
        0)
            echo -e "\n${GREEN}Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
