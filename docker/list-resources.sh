#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    List Docker Resources${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# List containers
echo -e "${GREEN}=== Running Containers ===${NC}"
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo -e "${GREEN}=== All Containers (including stopped) ===${NC}"
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""

# List images
echo -e "${GREEN}=== Docker Images ===${NC}"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
echo ""

# List networks
echo -e "${GREEN}=== Docker Networks ===${NC}"
docker network ls
echo ""

# List volumes
echo -e "${GREEN}=== Docker Volumes ===${NC}"
docker volume ls
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
printf "${GREEN}%-20s %5s${NC}\n" "Running Containers:" "$(docker ps -q | wc -l | tr -d ' ')"
printf "${GREEN}%-20s %5s${NC}\n" "Total Containers:" "$(docker ps -aq | wc -l | tr -d ' ')"
printf "${GREEN}%-20s %5s${NC}\n" "Images:" "$(docker images -q | wc -l | tr -d ' ')"
printf "${GREEN}%-20s %5s${NC}\n" "Networks:" "$(docker network ls -q | wc -l | tr -d ' ')"
printf "${GREEN}%-20s %5s${NC}\n" "Volumes:" "$(docker volume ls -q | wc -l | tr -d ' ')"

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
