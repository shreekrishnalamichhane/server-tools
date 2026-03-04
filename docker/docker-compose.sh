#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Docker Compose Operations${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if Docker Compose is available
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}Docker Compose is not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Install Docker Compose using the 'Install Docker' tool.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

echo -e "${GREEN}Docker Compose is available: ${COMPOSE_CMD}${NC}"
echo ""

echo -e -n "${BLUE}Enter path to docker-compose.yml directory (default: current directory): ${NC}"
read -r compose_dir
compose_dir=${compose_dir:-.}

if [ ! -f "$compose_dir/docker-compose.yml" ] && [ ! -f "$compose_dir/docker-compose.yaml" ]; then
    echo -e "${RED}No docker-compose.yml found in ${compose_dir}${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

cd "$compose_dir" || exit 1

echo ""
echo -e "${BLUE}Docker Compose Operations:${NC}"
echo ""
echo "  1. Start services (up -d)"
echo "  2. Stop services"
echo "  3. Restart services"
echo "  4. View service status"
echo "  5. View service logs"
echo "  6. Stop and remove containers"
echo "  7. Build/rebuild services"
echo "  8. Pull service images"
echo "  9. Execute command in service"
echo " 10. Scale services"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Starting services...${NC}"
        $COMPOSE_CMD up -d
        echo ""
        echo -e "${GREEN}✓ Services started.${NC}"
        echo ""
        echo -e "${BLUE}Running services:${NC}"
        $COMPOSE_CMD ps
        ;;
    
    2)
        echo ""
        echo -e "${YELLOW}Stopping services...${NC}"
        $COMPOSE_CMD stop
        echo -e "${GREEN}✓ Services stopped.${NC}"
        ;;
    
    3)
        echo ""
        echo -e "${YELLOW}Restarting services...${NC}"
        $COMPOSE_CMD restart
        echo -e "${GREEN}✓ Services restarted.${NC}"
        ;;
    
    4)
        echo ""
        echo -e "${GREEN}Service Status:${NC}"
        $COMPOSE_CMD ps
        ;;
    
    5)
        echo ""
        $COMPOSE_CMD ps --services
        echo ""
        echo -e -n "${BLUE}Enter service name (or leave empty for all): ${NC}"
        read -r service
        
        echo ""
        if [ -z "$service" ]; then
            echo -e "${GREEN}=== Logs for all services ===${NC}"
            echo ""
            $COMPOSE_CMD logs --tail=50
        else
            echo -e "${GREEN}=== Logs for ${service} ===${NC}"
            echo ""
            $COMPOSE_CMD logs --tail=50 "$service"
        fi
        ;;
    
    6)
        echo ""
        echo -e "${RED}This will stop and remove all containers defined in docker-compose.yml${NC}"
        echo -e -n "${YELLOW}Continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            echo ""
            echo -e -n "${YELLOW}Also remove volumes? (y/n): ${NC}"
            read -r remove_volumes
            
            if [[ $remove_volumes == [yY] ]]; then
                $COMPOSE_CMD down -v
            else
                $COMPOSE_CMD down
            fi
            echo -e "${GREEN}✓ Services stopped and removed.${NC}"
        else
            echo -e "${YELLOW}Operation cancelled.${NC}"
        fi
        ;;
    
    7)
        echo ""
        echo -e "${YELLOW}Building/rebuilding services...${NC}"
        echo ""
        echo -e -n "${BLUE}Build with --no-cache? (y/n): ${NC}"
        read -r no_cache
        
        if [[ $no_cache == [yY] ]]; then
            $COMPOSE_CMD build --no-cache
        else
            $COMPOSE_CMD build
        fi
        echo -e "${GREEN}✓ Build completed.${NC}"
        ;;
    
    8)
        echo ""
        echo -e "${YELLOW}Pulling service images...${NC}"
        $COMPOSE_CMD pull
        echo -e "${GREEN}✓ Images pulled.${NC}"
        ;;
    
    9)
        echo ""
        $COMPOSE_CMD ps --services
        echo ""
        echo -e -n "${BLUE}Enter service name: ${NC}"
        read -r service
        
        if [ -z "$service" ]; then
            echo -e "${RED}Service name cannot be empty.${NC}"
        else
            echo -e -n "${BLUE}Enter command to execute: ${NC}"
            read -r command
            
            if [ -z "$command" ]; then
                echo -e "${RED}Command cannot be empty.${NC}"
            else
                echo ""
                $COMPOSE_CMD exec "$service" $command
            fi
        fi
        ;;
    
    10)
        echo ""
        $COMPOSE_CMD ps --services
        echo ""
        echo -e -n "${BLUE}Enter service name: ${NC}"
        read -r service
        
        if [ -z "$service" ]; then
            echo -e "${RED}Service name cannot be empty.${NC}"
        else
            echo -e -n "${BLUE}Enter number of containers: ${NC}"
            read -r scale_num
            
            if [[ ! "$scale_num" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid number.${NC}"
            else
                echo ""
                echo -e "${YELLOW}Scaling ${service} to ${scale_num} container(s)...${NC}"
                $COMPOSE_CMD up -d --scale "$service=$scale_num"
                echo -e "${GREEN}✓ Service scaled.${NC}"
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
