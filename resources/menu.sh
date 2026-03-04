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
    echo -e "${CYAN}    System Resources Menu${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Resources menu loop
while true; do
    show_header
    echo -e "${GREEN}Available Tools:${NC}"
    echo ""
    echo "  1. System Overview"
    echo "  2. CPU Information"
    echo "  3. Memory Details"
    echo "  4. Disk Information"
    echo "  5. Network Information"
    echo "  6. Process Monitor"
    echo "  7. System Load & Uptime"
    echo "  8. Hardware Information"
    echo ""
    echo -e "${YELLOW}  0. Back to Main Menu${NC}"
    echo ""
    echo -e -n "${BLUE}Select a tool: ${NC}"
    read -r choice

    case $choice in
        1)
            bash "$SCRIPT_DIR/system-overview.sh"
            ;;
        2)
            bash "$SCRIPT_DIR/cpu-info.sh"
            ;;
        3)
            bash "$SCRIPT_DIR/memory-info.sh"
            ;;
        4)
            bash "$SCRIPT_DIR/disk-info.sh"
            ;;
        5)
            bash "$SCRIPT_DIR/network-info.sh"
            ;;
        6)
            bash "$SCRIPT_DIR/process-monitor.sh"
            ;;
        7)
            bash "$SCRIPT_DIR/load-uptime.sh"
            ;;
        8)
            bash "$SCRIPT_DIR/hardware-info.sh"
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
