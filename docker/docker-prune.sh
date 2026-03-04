#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Docker Prune (Cleanup)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# Show current disk usage
echo -e "${BLUE}Current Docker Disk Usage:${NC}"
docker system df
echo ""

# Cleanup options
echo -e "${GREEN}Cleanup Options:${NC}"
echo ""
echo "  1. Remove stopped containers"
echo "  2. Remove unused images"
echo "  3. Remove unused volumes"
echo "  4. Remove unused networks"
echo "  5. Remove all unused data (containers, images, networks, volumes)"
echo "  6. Full cleanup (including build cache) - USE WITH CAUTION"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Removing stopped containers...${NC}"
        if docker container prune -f 2>&1; then
            echo -e "${GREEN}✓ Stopped containers removed.${NC}"
        else
            echo -e "${RED}✗ Failed to remove stopped containers.${NC}"
        fi
        ;;
    
    2)
        echo ""
        echo -e "${YELLOW}This will remove:${NC}"
        echo "  - Dangling images (not tagged and not referenced by any container)"
        echo ""
        echo -e -n "${YELLOW}Continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            if docker image prune -f 2>&1; then
                echo -e "${GREEN}✓ Unused images removed.${NC}"
            else
                echo -e "${RED}✗ Failed to remove unused images.${NC}"
            fi
            echo ""
            echo -e -n "${YELLOW}Also remove unused tagged images? (y/n): ${NC}"
            read -r confirm_all
            
            if [[ $confirm_all == [yY] ]]; then
                if docker image prune -a -f 2>&1; then
                    echo -e "${GREEN}✓ All unused images removed.${NC}"
                else
                    echo -e "${RED}✗ Failed to remove all unused images.${NC}"
                fi
            fi
        fi
        ;;
    
    3)
        echo ""
        echo -e "${YELLOW}Removing unused volumes...${NC}"
        echo -e "${RED}WARNING: This will permanently delete data in unused volumes!${NC}"
        echo ""
        echo -e -n "${YELLOW}Continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            if docker volume prune -f 2>&1; then
                echo -e "${GREEN}✓ Unused volumes removed.${NC}"
            else
                echo -e "${RED}✗ Failed to remove unused volumes.${NC}"
            fi
        fi
        ;;
    
    4)
        echo ""
        echo -e "${YELLOW}Removing unused networks...${NC}"
        if docker network prune -f 2>&1; then
            echo -e "${GREEN}✓ Unused networks removed.${NC}"
        else
            echo -e "${RED}✗ Failed to remove unused networks.${NC}"
        fi
        ;;
    
    5)
        echo ""
        echo -e "${YELLOW}This will remove:${NC}"
        echo "  - All stopped containers"
        echo "  - All networks not used by at least one container"
        echo "  - All dangling images"
        echo "  - All unused volumes"
        echo ""
        echo -e "${RED}WARNING: This is a destructive operation!${NC}"
        echo -e -n "${YELLOW}Continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            if docker system prune --volumes -f 2>&1; then
                echo -e "${GREEN}✓ All unused data removed.${NC}"
            else
                echo -e "${RED}✗ Failed to remove all unused data.${NC}"
            fi
        fi
        ;;
    
    6)
        echo ""
        echo -e "${RED}⚠️  FULL CLEANUP - USE WITH CAUTION ⚠️${NC}"
        echo ""
        echo -e "${YELLOW}This will remove:${NC}"
        echo "  - All stopped containers"
        echo "  - All networks not used by at least one container"
        echo "  - All images without at least one container associated"
        echo "  - All build cache"
        echo "  - All unused volumes"
        echo ""
        echo -e "${RED}This will free up maximum space but remove almost everything!${NC}"
        echo ""
        echo -e -n "${YELLOW}Are you absolutely sure? (type 'yes' to confirm): ${NC}"
        read -r confirm
        
        if [[ $confirm == "yes" ]]; then
            if docker system prune -a --volumes -f 2>&1; then
                echo -e "${GREEN}✓ Full cleanup completed.${NC}"
            else
                echo -e "${RED}✗ Full cleanup failed.${NC}"
            fi
        else
            echo -e "${YELLOW}Cleanup cancelled.${NC}"
        fi
        ;;
    
    0)
        echo -e "${YELLOW}Cleanup cancelled.${NC}"
        ;;
    
    *)
        echo -e "${RED}Invalid option.${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}Updated Docker Disk Usage:${NC}"
docker system df
echo ""

echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
