#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Process Monitor${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Process Summary
echo -e "${GREEN}=== Process Summary ===${NC}"
echo ""

total_processes=$(ps aux | wc -l | tr -d ' ')
running=$(ps aux | grep -c " R ")
sleeping=$(ps aux | grep -c " S ")
stopped=$(ps aux | grep -c " T ")
zombie=$(ps aux | grep -c " Z ")

printf "%-25s %10s\n" "Total Processes:" "$total_processes"
printf "%-25s %10s\n" "Running:" "$running"
printf "%-25s %10s\n" "Sleeping:" "$sleeping"
printf "%-25s %10s\n" "Stopped:" "$stopped"
printf "%-25s %10s\n" "Zombie:" "$zombie"
echo ""

# Top CPU Consuming Processes
echo -e "${GREEN}=== Top 10 CPU Consuming Processes ===${NC}"
echo ""
printf "${CYAN}%-8s %-10s %-8s %-8s %s${NC}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
echo "--------------------------------------------------------------------------------"

if command -v ps &> /dev/null; then
    ps aux --sort=-pcpu 2>/dev/null | head -11 | tail -10 | awk '{printf "%-8s %-10s %-8s %-8s %s\n", $2, $1, $3"%", $4"%", $11}' || \
    ps aux 2>/dev/null | sort -rn -k3 | head -10 | awk '{printf "%-8s %-10s %-8s %-8s %s\n", $2, $1, $3"%", $4"%", $11}'
fi
echo ""

# Top Memory Consuming Processes
echo -e "${GREEN}=== Top 10 Memory Consuming Processes ===${NC}"
echo ""
printf "${CYAN}%-8s %-10s %-8s %-8s %s${NC}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
echo "--------------------------------------------------------------------------------"

if command -v ps &> /dev/null; then
    ps aux --sort=-pmem 2>/dev/null | head -11 | tail -10 | awk '{printf "%-8s %-10s %-8s %-8s %s\n", $2, $1, $3"%", $4"%", $11}' || \
    ps aux 2>/dev/null | sort -rn -k4 | head -10 | awk '{printf "%-8s %-10s %-8s %-8s %s\n", $2, $1, $3"%", $4"%", $11}'
fi
echo ""

# Interactive Options
echo -e "${GREEN}Options:${NC}"
echo ""
echo "  1. Search for a process"
echo "  2. Kill a process"
echo "  3. View process tree"
echo "  4. Monitor processes (htop/top)"
echo "  5. View all processes"
echo "  0. Back to menu"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e -n "${BLUE}Enter process name to search: ${NC}"
        read -r process_name
        
        if [ -z "$process_name" ]; then
            echo -e "${RED}✗ Process name cannot be empty.${NC}"
        else
            echo ""
            echo -e "${GREEN}=== Matching Processes ===${NC}"
            echo ""
            printf "${CYAN}%-8s %-10s %-8s %-8s %s${NC}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
            echo "--------------------------------------------------------------------------------"
            ps aux | grep -i "$process_name" | grep -v grep | awk '{printf "%-8s %-10s %-8s %-8s %s\n", $2, $1, $3"%", $4"%", $11}'
            
            if [ $(ps aux | grep -i "$process_name" | grep -v grep | wc -l) -eq 0 ]; then
                echo -e "${YELLOW}No processes found matching '$process_name'${NC}"
            fi
        fi
        ;;
    
    2)
        echo ""
        echo -e -n "${BLUE}Enter PID to kill: ${NC}"
        read -r pid
        
        if [ -z "$pid" ]; then
            echo -e "${RED}✗ PID cannot be empty.${NC}"
        elif ! [[ "$pid" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}✗ Invalid PID. Must be a number.${NC}"
        elif ! ps -p "$pid" &> /dev/null; then
            echo -e "${RED}✗ Process $pid does not exist.${NC}"
        else
            echo ""
            echo -e "${BLUE}Process details:${NC}"
            ps -p "$pid" -o pid,user,pcpu,pmem,comm
            echo ""
            echo -e "${YELLOW}Kill options:${NC}"
            echo "  1. SIGTERM (graceful shutdown)"
            echo "  2. SIGKILL (force kill)"
            echo "  0. Cancel"
            echo ""
            echo -e -n "${BLUE}Select: ${NC}"
            read -r kill_choice
            
            case $kill_choice in
                1)
                    if kill -15 "$pid" 2>&1; then
                        echo -e "${GREEN}✓ SIGTERM sent to process $pid${NC}"
                    else
                        echo -e "${RED}✗ Failed to kill process. May require root privileges.${NC}"
                    fi
                    ;;
                2)
                    if kill -9 "$pid" 2>&1; then
                        echo -e "${GREEN}✓ SIGKILL sent to process $pid${NC}"
                    else
                        echo -e "${RED}✗ Failed to kill process. May require root privileges.${NC}"
                    fi
                    ;;
                0)
                    echo -e "${YELLOW}Cancelled.${NC}"
                    ;;
                *)
                    echo -e "${RED}✗ Invalid option.${NC}"
                    ;;
            esac
        fi
        ;;
    
    3)
        echo ""
        if command -v pstree &> /dev/null; then
            pstree -p | less
        elif ps --version 2>&1 | grep -q "procps"; then
            ps auxf | less
        else
            echo -e "${YELLOW}Process tree view not available${NC}"
        fi
        ;;
    
    4)
        clear
        if command -v htop &> /dev/null; then
            htop
        elif command -v top &> /dev/null; then
            top
        else
            echo -e "${RED}Neither htop nor top is available${NC}"
        fi
        ;;
    
    5)
        echo ""
        ps aux | less
        ;;
    
    0)
        echo -e "${YELLOW}Returning to menu...${NC}"
        sleep 1
        exit 0
        ;;
    
    *)
        echo -e "${RED}✗ Invalid option.${NC}"
        ;;
esac

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
