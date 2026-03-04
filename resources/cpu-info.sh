#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    CPU Information${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# CPU Details
echo -e "${GREEN}=== CPU Details ===${NC}"
echo ""

if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
    cpu_physical=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l | tr -d ' ')
    cpu_threads=$(grep "siblings" /proc/cpuinfo | head -1 | awk '{print $3}')
    cpu_mhz=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}')
    
    printf "%-25s %s\n" "Model:" "$cpu_model"
    printf "%-25s %s\n" "Physical CPUs:" "$cpu_physical"
    printf "%-25s %s\n" "CPU Cores:" "$cpu_cores"
    printf "%-25s %s\n" "Threads per Core:" "$cpu_threads"
    printf "%-25s %s MHz\n" "Current Speed:" "$cpu_mhz"
    
    # Cache information
    if grep -q "cache size" /proc/cpuinfo; then
        cache_size=$(grep -m1 "cache size" /proc/cpuinfo | cut -d: -f2 | xargs)
        printf "%-25s %s\n" "Cache Size:" "$cache_size"
    fi
elif command -v sysctl &> /dev/null; then
    # macOS/BSD
    cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null)
    
    if [ -n "$cpu_model" ]; then
        printf "%-25s %s\n" "Model:" "$cpu_model"
    fi
    if [ -n "$cpu_cores" ]; then
        printf "%-25s %s\n" "CPU Cores:" "$cpu_cores"
    fi
fi
echo ""

# CPU Usage
echo -e "${GREEN}=== CPU Usage ===${NC}"
echo ""

if command -v mpstat &> /dev/null; then
    mpstat 1 1 | tail -2
elif command -v top &> /dev/null; then
    # Using top for CPU usage
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3, $5, $7}')
        echo "CPU Usage: $cpu_usage"
    else
        cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'%' -f1)
        if [ -n "$cpu_idle" ]; then
            cpu_used=$(echo "100 - $cpu_idle" | bc 2>/dev/null || awk "BEGIN {print 100 - $cpu_idle}")
            printf "%-25s %.1f%%\n" "CPU Used:" "$cpu_used"
            printf "%-25s %.1f%%\n" "CPU Idle:" "$cpu_idle"
        fi
    fi
else
    echo -e "${YELLOW}CPU usage tools not available${NC}"
fi
echo ""

# Load Average
echo -e "${GREEN}=== Load Average ===${NC}"
echo ""
uptime | awk -F'load average:' '{print $2}' | awk '{printf "%-25s %s\n%-25s %s\n%-25s %s\n", "1 minute:", $1, "5 minutes:", $2, "15 minutes:", $3}'
echo ""

# Per-Core CPU Usage
echo -e "${GREEN}=== Per-Core CPU Usage ===${NC}"
echo ""

if command -v mpstat &> /dev/null; then
    echo -e "${BLUE}Collecting data for 2 seconds...${NC}"
    echo ""
    mpstat -P ALL 2 1 | grep -v "^$" | tail -n +3
elif [ -f /proc/stat ]; then
    echo -e "${CYAN}CPU   USER   SYSTEM   IDLE${NC}"
    echo "------------------------------------"
    grep "^cpu[0-9]" /proc/stat | awk '{
        cpu=$1;
        user=$2;
        system=$4;
        idle=$5;
        total=user+system+idle;
        if(total>0) {
            printf "%-6s %5.1f%% %6.1f%% %6.1f%%\n", cpu, (user/total)*100, (system/total)*100, (idle/total)*100
        }
    }'
else
    echo -e "${YELLOW}Per-core usage not available${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
