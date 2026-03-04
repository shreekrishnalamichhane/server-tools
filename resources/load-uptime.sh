#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    System Load & Uptime${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# System Uptime
echo -e "${GREEN}=== System Uptime ===${NC}"
echo ""
uptime
echo ""

uptime_pretty=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}')

printf "%-25s %s\n" "Uptime:" "$uptime_pretty"
[ -n "$boot_time" ] && printf "%-25s %s\n" "Last Boot:" "$boot_time"
echo ""

# Load Average
echo -e "${GREEN}=== Load Average ===${NC}"
echo ""

load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
load_1min=$(echo "$load_avg" | awk -F',' '{print $1}' | xargs)
load_5min=$(echo "$load_avg" | awk -F',' '{print $2}' | xargs)
load_15min=$(echo "$load_avg" | awk -F',' '{print $3}' | xargs)

cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)

printf "%-25s %s\n" "1 minute:" "$load_1min"
printf "%-25s %s\n" "5 minutes:" "$load_5min"
printf "%-25s %s\n" "15 minutes:" "$load_15min"
printf "%-25s %s\n" "CPU Cores:" "$cpu_cores"
echo ""

# Load interpretation
load_1min_int=$(echo "$load_1min" | cut -d'.' -f1)
if [ -n "$load_1min_int" ] && [ "$load_1min_int" -gt "$cpu_cores" ]; then
    echo -e "${RED}⚠ System is under heavy load!${NC}"
    echo -e "Load average ($load_1min) exceeds CPU core count ($cpu_cores)"
elif [ -n "$load_1min_int" ] && [ "$load_1min_int" -gt $((cpu_cores * 70 / 100)) ]; then
    echo -e "${YELLOW}⚠ System load is moderate${NC}"
else
    echo -e "${GREEN}✓ System load is normal${NC}"
fi
echo ""

# CPU Usage
echo -e "${GREEN}=== Current CPU Usage ===${NC}"
echo ""

if command -v top &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        top -l 1 | grep "CPU usage"
    else
        top -bn1 | grep "Cpu(s)"
    fi
fi
echo ""

# Memory Usage
echo -e "${GREEN}=== Current Memory Usage ===${NC}"
echo ""

if command -v free &> /dev/null; then
    free -h | grep -E "^Mem:|^Swap:"
elif command -v vm_stat &> /dev/null; then
    vm_stat | grep -E "Pages free|Pages active|Pages wired"
fi
echo ""

# Load History (if available)
if [ -f /proc/loadavg ]; then
    echo -e "${GREEN}=== Load Average Details ===${NC}"
    echo ""
    cat /proc/loadavg
    echo ""
fi

# System Statistics
echo -e "${GREEN}=== System Statistics ===${NC}"
echo ""

if command -v vmstat &> /dev/null; then
    echo -e "${BLUE}System Performance (vmstat):${NC}"
    echo ""
    vmstat 1 3
    echo ""
fi

# Who is logged in
echo -e "${GREEN}=== Current Users ===${NC}"
echo ""
who
if [ $(who | wc -l) -eq 0 ]; then
    echo -e "${YELLOW}No users currently logged in${NC}"
fi
echo ""

# Last logins
echo -e "${GREEN}=== Recent Logins ===${NC}"
echo ""
if command -v last &> /dev/null; then
    last -n 10 -w 2>/dev/null | head -10
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
