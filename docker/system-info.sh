#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Docker System Info & Disk Usage${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# Docker system information
echo -e "${GREEN}=== System Information ===${NC}"
echo ""
docker version
echo ""

echo -e "${GREEN}=== Docker Daemon Info ===${NC}"
echo ""
docker info 2>/dev/null | grep -E "Server Version|Storage Driver|Logging Driver|Cgroup Driver|Plugins|Swarm|Runtimes|Default Runtime|Operating System|OSType|Architecture|CPUs|Total Memory|Docker Root Dir"
echo ""

# Disk usage
echo -e "${GREEN}=== Disk Usage ===${NC}"
echo ""
docker system df
echo ""

echo -e "${GREEN}=== Detailed Disk Usage ===${NC}"
echo ""
docker system df -v
echo ""

# Resource counts
echo -e "${GREEN}=== Resource Summary ===${NC}"
echo ""
running_containers=$(docker ps -q | wc -l | tr -d ' ')
total_containers=$(docker ps -aq | wc -l | tr -d ' ')
images=$(docker images -q | wc -l | tr -d ' ')
volumes=$(docker volume ls -q | wc -l | tr -d ' ')
networks=$(docker network ls -q | wc -l | tr -d ' ')

printf "%-25s ${GREEN}%5s${NC}\n" "Running Containers:" "$running_containers"
printf "%-25s ${GREEN}%5s${NC}\n" "Total Containers:" "$total_containers"
printf "%-25s ${GREEN}%5s${NC}\n" "Images:" "$images"
printf "%-25s ${GREEN}%5s${NC}\n" "Volumes:" "$volumes"
printf "%-25s ${GREEN}%5s${NC}\n" "Networks:" "$networks"
echo ""

# Resource usage statistics
echo -e "${GREEN}=== Container Resource Usage ===${NC}"
echo ""
if [ "$running_containers" -gt 0 ]; then
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
else
    echo -e "${YELLOW}No running containers.${NC}"
fi

echo ""

# Show reclaimable space
echo -e "${GREEN}=== Reclaimable Space ===${NC}"
echo ""

stopped_containers=$(docker ps -aq -f status=exited | wc -l | tr -d ' ')
dangling_images=$(docker images -qf "dangling=true" | wc -l | tr -d ' ')
unused_volumes=$(docker volume ls -qf "dangling=true" | wc -l | tr -d ' ')

printf "%-25s ${YELLOW}%5s${NC}\n" "Stopped containers:" "$stopped_containers"
printf "%-25s ${YELLOW}%5s${NC}\n" "Dangling images:" "$dangling_images"
printf "%-25s ${YELLOW}%5s${NC}\n" "Unused volumes:" "$unused_volumes"
echo ""

if [ "$stopped_containers" -gt 0 ] || [ "$dangling_images" -gt 0 ] || [ "$unused_volumes" -gt 0 ]; then
    echo -e "${YELLOW}Tip: Use 'Docker Prune' tool to reclaim space.${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
