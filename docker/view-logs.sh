#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    View Container Logs${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# List all containers
echo -e "${GREEN}All Containers:${NC}"
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""

echo -e -n "${BLUE}Enter container name or ID: ${NC}"
read -r container

if [ -z "$container" ]; then
    echo -e "${RED}Container name/ID cannot be empty.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# Check if container exists
if ! docker ps -a --format "{{.Names}}" | grep -q "^${container}$" && ! docker ps -a --format "{{.ID}}" | grep -q "^${container}"; then
    echo -e "${RED}Container '${container}' not found.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

echo ""
echo -e "${BLUE}Log Options:${NC}"
echo ""
echo "  1. View all logs"
echo "  2. View last 50 lines"
echo "  3. View last 100 lines"
echo "  4. View custom number of lines"
echo "  5. Follow logs (real-time)"
echo "  6. View logs with timestamps"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}=== Logs for ${container} ===${NC}"
        echo ""
        if ! docker logs "$container" 2>&1; then
            echo -e "${RED}✗ Failed to retrieve logs.${NC}"
        fi
        ;;
    
    2)
        echo ""
        echo -e "${GREEN}=== Last 50 lines for ${container} ===${NC}"
        echo ""
        if ! docker logs --tail 50 "$container" 2>&1; then
            echo -e "${RED}✗ Failed to retrieve logs.${NC}"
        fi
        ;;
    
    3)
        echo ""
        echo -e "${GREEN}=== Last 100 lines for ${container} ===${NC}"
        echo ""
        if ! docker logs --tail 100 "$container" 2>&1; then
            echo -e "${RED}✗ Failed to retrieve logs.${NC}"
        fi
        ;;
    
    4)
        echo ""
        echo -e -n "${BLUE}Enter number of lines: ${NC}"
        read -r lines
        
        if [[ ! "$lines" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}✗ Invalid number.${NC}"
        else
            echo ""
            echo -e "${GREEN}=== Last ${lines} lines for ${container} ===${NC}"
            echo ""
            if ! docker logs --tail "$lines" "$container" 2>&1; then
                echo -e "${RED}✗ Failed to retrieve logs.${NC}"
            fi
        fi
        ;;
    
    5)
        echo ""
        echo -e "${GREEN}=== Following logs for ${container} (Press Ctrl+C to stop) ===${NC}"
        echo ""
        if ! docker logs -f "$container" 2>&1; then
            echo -e "${RED}✗ Failed to follow logs.${NC}"
        fi
        ;;
    
    6)
        echo ""
        echo -e "${GREEN}=== Logs with timestamps for ${container} ===${NC}"
        echo ""
        if ! docker logs --timestamps "$container" 2>&1; then
            echo -e "${RED}✗ Failed to retrieve logs.${NC}"
        fi
        ;;
    
    0)
        echo -e "${YELLOW}Operation cancelled.${NC}"
        ;;
    
    *)
        echo -e "${RED}Invalid option.${NC}"
        ;;
esac

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
