#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    System Overview${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# System Information
echo -e "${GREEN}=== System Information ===${NC}"
echo ""
printf "%-25s %s\n" "Hostname:" "$(hostname)"
printf "%-25s %s\n" "OS:" "$(uname -s)"
printf "%-25s %s\n" "Kernel:" "$(uname -r)"
printf "%-25s %s\n" "Architecture:" "$(uname -m)"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    printf "%-25s %s\n" "Distribution:" "$PRETTY_NAME"
fi

printf "%-25s %s\n" "Uptime:" "$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
echo ""

# CPU Summary
echo -e "${GREEN}=== CPU Summary ===${NC}"
echo ""
cpu_model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)
cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)
cpu_load=$(uptime | awk -F'load average:' '{print $2}' | xargs)

if [ -n "$cpu_model" ]; then
    printf "%-25s %s\n" "CPU Model:" "$cpu_model"
fi
printf "%-25s %s\n" "CPU Cores:" "$cpu_cores"
printf "%-25s %s\n" "Load Average:" "$cpu_load"
echo ""

# Memory Summary
echo -e "${GREEN}=== Memory Summary ===${NC}"
echo ""
if command -v free &> /dev/null; then
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_free=$(free -h | awk '/^Mem:/ {print $4}')
    mem_percent=$(free | awk '/^Mem:/ {printf "%.1f%%", $3/$2 * 100}')
    
    printf "%-25s %s\n" "Total:" "$mem_total"
    printf "%-25s %s\n" "Used:" "$mem_used ($mem_percent)"
    printf "%-25s %s\n" "Free:" "$mem_free"
else
    echo -e "${YELLOW}Memory info not available${NC}"
fi
echo ""

# Disk Summary
echo -e "${GREEN}=== Disk Summary ===${NC}"
echo ""
df -h / | awk 'NR==2 {printf "%-25s %s\n%-25s %s\n%-25s %s\n%-25s %s\n", "Filesystem:", $1, "Size:", $2, "Used:", $3 " (" $5 ")", "Available:", $4}'
echo ""

# Network Summary
echo -e "${GREEN}=== Network Summary ===${NC}"
echo ""
if command -v ip &> /dev/null; then
    active_interfaces=$(ip -br addr show | awk '$2=="UP" {print $1}' | wc -l | tr -d ' ')
    printf "%-25s %s\n" "Active Interfaces:" "$active_interfaces"
    
    main_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    if [ -n "$main_ip" ]; then
        printf "%-25s %s\n" "Primary IP:" "$main_ip"
    fi
elif command -v ifconfig &> /dev/null; then
    active_interfaces=$(ifconfig | grep -c "^[a-z]")
    printf "%-25s %s\n" "Active Interfaces:" "$active_interfaces"
fi
echo ""

# Process Summary
echo -e "${GREEN}=== Process Summary ===${NC}"
echo ""
total_processes=$(ps aux | wc -l | tr -d ' ')
running_processes=$(ps aux | grep -c " R ")
sleeping_processes=$(ps aux | grep -c " S ")

printf "%-25s %s\n" "Total Processes:" "$total_processes"
printf "%-25s %s\n" "Running:" "$running_processes"
printf "%-25s %s\n" "Sleeping:" "$sleeping_processes"
echo ""

# Logged in Users
echo -e "${GREEN}=== Logged in Users ===${NC}"
echo ""
who | awk '{printf "%-20s %-15s %s\n", $1, $2, $3 " " $4}'
if [ $(who | wc -l) -eq 0 ]; then
    echo -e "${YELLOW}No users currently logged in${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
