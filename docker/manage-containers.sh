#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Manage Containers${NC}"
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

# Management options
echo -e "${BLUE}Management Options:${NC}"
echo ""
echo "  1. Start a container"
echo "  2. Stop a container"
echo "  3. Restart a container"
echo "  4. Pause a container"
echo "  5. Unpause a container"
echo "  6. Start all stopped containers"
echo "  7. Stop all running containers"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}Container name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Starting container ${container}...${NC}"
            if docker start "$container"; then
                echo -e "${GREEN}✓ Container started successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to start container.${NC}"
            fi
        fi
        ;;
    
    2)
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}Container name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Stopping container ${container}...${NC}"
            if docker stop "$container"; then
                echo -e "${GREEN}✓ Container stopped successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to stop container.${NC}"
            fi
        fi
        ;;
    
    3)
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}Container name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Restarting container ${container}...${NC}"
            if docker restart "$container"; then
                echo -e "${GREEN}✓ Container restarted successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to restart container.${NC}"
            fi
        fi
        ;;
    
    4)
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}Container name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Pausing container ${container}...${NC}"
            if docker pause "$container"; then
                echo -e "${GREEN}✓ Container paused successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to pause container.${NC}"
            fi
        fi
        ;;
    
    5)
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}Container name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Unpausing container ${container}...${NC}"
            if docker unpause "$container"; then
                echo -e "${GREEN}✓ Container unpaused successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to unpause container.${NC}"
            fi
        fi
        ;;
    
    6)
        echo ""
        stopped_containers=$(docker ps -aq -f status=exited)
        
        if [ -z "$stopped_containers" ]; then
            echo -e "${YELLOW}No stopped containers found.${NC}"
        else
            echo -e "${YELLOW}Starting all stopped containers...${NC}"
            docker start $stopped_containers
            echo -e "${GREEN}✓ All stopped containers started.${NC}"
        fi
        ;;
    
    7)
        echo ""
        echo -e "${RED}This will stop all running containers!${NC}"
        echo -e -n "${YELLOW}Are you sure? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            running_containers=$(docker ps -q)
            
            if [ -z "$running_containers" ]; then
                echo -e "${YELLOW}No running containers found.${NC}"
            else
                echo -e "${YELLOW}Stopping all running containers...${NC}"
                docker stop $running_containers
                echo -e "${GREEN}✓ All containers stopped.${NC}"
            fi
        else
            echo -e "${YELLOW}Operation cancelled.${NC}"
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
