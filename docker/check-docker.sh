#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Check Docker & Info${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"
echo ""

# Docker version
echo -e "${BLUE}Docker Version:${NC}"
docker --version
echo ""

# Docker info
echo -e "${BLUE}Docker Info:${NC}"
server_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
os_type=$(docker info --format '{{.OperatingSystem}}' 2>/dev/null)
total_mem=$(docker info --format '{{.MemTotal}}' 2>/dev/null | numfmt --to=iec 2>/dev/null || docker info --format '{{.MemTotal}}' 2>/dev/null)
cpus=$(docker info --format '{{.NCPU}}' 2>/dev/null)
running=$(docker info --format '{{.ContainersRunning}}' 2>/dev/null)
paused=$(docker info --format '{{.ContainersPaused}}' 2>/dev/null)
stopped=$(docker info --format '{{.ContainersStopped}}' 2>/dev/null)

printf "%-20s %s\n" "Server Version:" "$server_version"
printf "%-20s %s\n" "Operating System:" "$os_type"
printf "%-20s %s\n" "Total Memory:" "$total_mem"
printf "%-20s %s\n" "CPUs:" "$cpus"
printf "%-20s %s\n" "Running:" "$running"
printf "%-20s %s\n" "Paused:" "$paused"
printf "%-20s %s\n" "Stopped:" "$stopped"
echo ""

# Check if Docker daemon is running
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${RED}✗ Docker daemon is not running${NC}"
fi

echo ""

# Docker Compose version (if installed)
if command -v docker-compose &> /dev/null; then
    compose_ver=$(docker-compose --version)
    printf "%-20s %s\n" "Docker Compose:" "$compose_ver"
elif docker compose version &> /dev/null; then
    compose_ver=$(docker compose version)
    printf "%-20s %s\n" "Docker Compose:" "$compose_ver"
else
    echo -e "${YELLOW}Docker Compose is not installed${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
