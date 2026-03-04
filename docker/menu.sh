#!/bin/bash

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display header
show_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}    Docker Tools${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Docker menu loop
while true; do
    show_header
    echo -e "${GREEN}Available Tools:${NC}"
    echo ""
    echo "  1. Check Docker & Info"
    echo "  2. Install Docker & Related Tools"
    echo "  3. List Containers, Images & Networks"
    echo "  4. Export Docker Images"
    echo "  5. Docker Prune (Cleanup)"
    echo "  6. Start/Stop/Restart Containers"
    echo "  7. View Container Logs"
    echo "  8. Remove Containers/Images"
    echo "  9. Docker Compose Operations"
    echo " 10. Docker System Info & Disk Usage"
    echo ""
    echo -e "${YELLOW}  0. Back to Main Menu${NC}"
    echo ""
    echo -e -n "${BLUE}Select a tool: ${NC}"
    read -r choice

    case $choice in
        1)
            bash "$SCRIPT_DIR/check-docker.sh"
            ;;
        2)
            bash "$SCRIPT_DIR/install-docker.sh"
            ;;
        3)
            bash "$SCRIPT_DIR/list-resources.sh"
            ;;
        4)
            bash "$SCRIPT_DIR/export-images.sh"
            ;;
        5)
            bash "$SCRIPT_DIR/docker-prune.sh"
            ;;
        6)
            bash "$SCRIPT_DIR/manage-containers.sh"
            ;;
        7)
            bash "$SCRIPT_DIR/view-logs.sh"
            ;;
        8)
            bash "$SCRIPT_DIR/remove-resources.sh"
            ;;
        9)
            bash "$SCRIPT_DIR/docker-compose.sh"
            ;;
        10)
            bash "$SCRIPT_DIR/system-info.sh"
            ;;
        0)
            break
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
