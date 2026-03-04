#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Remove Docker Resources${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

echo -e "${BLUE}Remove Options:${NC}"
echo ""
echo "  1. Remove a specific container"
echo "  2. Remove a specific image"
echo "  3. Remove a specific volume"
echo "  4. Remove a specific network"
echo "  5. Remove all stopped containers"
echo "  6. Remove multiple containers"
echo "  7. Remove multiple images"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}All Containers:${NC}"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
        echo ""
        echo -e -n "${BLUE}Enter container name or ID: ${NC}"
        read -r container
        
        if [ -z "$container" ]; then
            echo -e "${RED}✗ Container name/ID cannot be empty.${NC}"
        else
            # Check if container is running
            if docker ps -q -f name="^${container}$" | grep -q .; then
                echo -e "${YELLOW}Container is running. Stopping first...${NC}"
                if ! docker stop "$container" 2>&1; then
                    echo -e "${RED}✗ Failed to stop container.${NC}"
                    echo ""
                    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                    read
                    continue
                fi
                echo -e "${GREEN}✓ Container stopped${NC}"
            fi
            
            echo -e "${YELLOW}Removing container ${container}...${NC}"
            if docker rm "$container" 2>&1; then
                echo -e "${GREEN}✓ Container removed successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to remove container. Check if container exists.${NC}"
            fi
        fi
        ;;
    
    2)
        echo ""
        echo -e "${GREEN}All Images:${NC}"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
        echo ""
        echo -e -n "${BLUE}Enter image name (repository:tag) or ID: ${NC}"
        read -r image
        
        if [ -z "$image" ]; then
            echo -e "${RED}✗ Image name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Removing image ${image}...${NC}"
            if docker rmi "$image" 2>&1; then
                echo -e "${GREEN}✓ Image removed successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to remove image.${NC}"
                echo -e "${YELLOW}Image may be in use by a container or has dependent images.${NC}"
                echo ""
                echo -e -n "${YELLOW}Force remove? (y/n): ${NC}"
                read -r force
                if [[ $force == [yY] ]]; then
                    if docker rmi -f "$image" 2>&1; then
                        echo -e "${GREEN}✓ Image force removed.${NC}"
                    else
                        echo -e "${RED}✗ Failed to force remove image. Check if image exists.${NC}"
                    fi
                fi
            fi
        fi
        ;;
    
    3)
        echo ""
        echo -e "${GREEN}All Volumes:${NC}"
        docker volume ls
        echo ""
        echo -e -n "${BLUE}Enter volume name: ${NC}"
        read -r volume
        
        if [ -z "$volume" ]; then
            echo -e "${RED}✗ Volume name cannot be empty.${NC}"
        else
            echo -e "${RED}WARNING: This will permanently delete the volume data!${NC}"
            echo -e -n "${YELLOW}Are you sure? (y/n): ${NC}"
            read -r confirm
            
            if [[ $confirm == [yY] ]]; then
                echo -e "${YELLOW}Removing volume ${volume}...${NC}"
                if docker volume rm "$volume" 2>&1; then
                    echo -e "${GREEN}✓ Volume removed successfully.${NC}"
                else
                    echo -e "${RED}✗ Failed to remove volume. Volume may be in use or doesn't exist.${NC}"
                fi
            else
                echo -e "${YELLOW}Operation cancelled.${NC}"
            fi
        fi
        ;;
    
    4)
        echo ""
        echo -e "${GREEN}All Networks:${NC}"
        docker network ls
        echo ""
        echo -e -n "${BLUE}Enter network name or ID: ${NC}"
        read -r network
        
        if [ -z "$network" ]; then
            echo -e "${RED}✗ Network name/ID cannot be empty.${NC}"
        else
            echo -e "${YELLOW}Removing network ${network}...${NC}"
            if docker network rm "$network" 2>&1; then
                echo -e "${GREEN}✓ Network removed successfully.${NC}"
            else
                echo -e "${RED}✗ Failed to remove network. Network may be in use or doesn't exist.${NC}"
            fi
        fi
        ;;
    
    5)
        echo ""
        stopped_containers=$(docker ps -aq -f status=exited)
        
        if [ -z "$stopped_containers" ]; then
            echo -e "${YELLOW}No stopped containers found.${NC}"
        else
            echo -e "${YELLOW}Found $(echo $stopped_containers | wc -w) stopped container(s).${NC}"
            echo -e -n "${YELLOW}Remove all? (y/n): ${NC}"
            read -r confirm
            
            if [[ $confirm == [yY] ]]; then
                if docker rm $stopped_containers 2>&1; then
                    echo -e "${GREEN}✓ All stopped containers removed.${NC}"
                else
                    echo -e "${RED}✗ Failed to remove some containers.${NC}"
                fi
            else
                echo -e "${YELLOW}Operation cancelled.${NC}"
            fi
        fi
        ;;
    
    6)
        echo ""
        echo -e "${GREEN}All Containers:${NC}"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
        echo ""
        echo -e "${BLUE}Enter container names or IDs separated by spaces:${NC}"
        read -r containers
        
        if [ -z "$containers" ]; then
            echo -e "${RED}No containers specified.${NC}"
        else
            echo -e -n "${YELLOW}Remove these containers? (y/n): ${NC}"
            read -r confirm
            
            if [[ $confirm == [yY] ]]; then
                for container in $containers; do
                    if docker ps -q -f name="^${container}$" | grep -q .; then
                        echo -e "${YELLOW}Stopping ${container}...${NC}"
                        if ! docker stop "$container" 2>&1; then
                            echo -e "${RED}✗ Failed to stop ${container}${NC}"
                        fi
                    fi
                done
                
                if docker rm $containers 2>&1; then
                    echo -e "${GREEN}✓ Containers removed.${NC}"
                else
                    echo -e "${RED}✗ Failed to remove some containers.${NC}"
                fi
            else
                echo -e "${YELLOW}Operation cancelled.${NC}"
            fi
        fi
        ;;
    
    7)
        echo ""
        echo -e "${GREEN}All Images:${NC}"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
        echo ""
        echo -e "${BLUE}Enter image names or IDs separated by spaces:${NC}"
        read -r images
        
        if [ -z "$images" ]; then
            echo -e "${RED}No images specified.${NC}"
        else
            echo -e -n "${YELLOW}Remove these images? (y/n): ${NC}"
            read -r confirm
            
            if [[ $confirm == [yY] ]]; then
                if docker rmi $images 2>&1; then
                    echo -e "${GREEN}✓ Images removed.${NC}"
                else
                    echo -e "${RED}✗ Failed to remove some images. They may be in use.${NC}"
                fi
            else
                echo -e "${YELLOW}Operation cancelled.${NC}"
            fi
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
