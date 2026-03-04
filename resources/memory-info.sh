#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Memory Details${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Memory Overview
echo -e "${GREEN}=== Memory Overview ===${NC}"
echo ""

if command -v free &> /dev/null; then
    # Linux
    free -h
    echo ""
    
    # Percentage calculations
    mem_total=$(free | awk '/^Mem:/ {print $2}')
    mem_used=$(free | awk '/^Mem:/ {print $3}')
    mem_free=$(free | awk '/^Mem:/ {print $4}')
    mem_available=$(free | awk '/^Mem:/ {print $7}')
    mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc 2>/dev/null || awk "BEGIN {printf \"%.1f\", $mem_used * 100 / $mem_total}")
    
    echo -e "${GREEN}=== Memory Usage Percentage ===${NC}"
    echo ""
    printf "%-25s %.1f%%\n" "Memory Used:" "$mem_percent"
    printf "%-25s %.1f%%\n" "Memory Free:" "$(echo "scale=1; 100 - $mem_percent" | bc 2>/dev/null || awk "BEGIN {printf \"%.1f\", 100 - $mem_percent}")"
    
elif command -v vm_stat &> /dev/null; then
    # macOS
    vm_stat
    echo ""
    
    page_size=$(pagesize 2>/dev/null || echo 4096)
    vm_stats=$(vm_stat)
    
    pages_free=$(echo "$vm_stats" | awk '/Pages free/ {print $3}' | tr -d '.')
    pages_active=$(echo "$vm_stats" | awk '/Pages active/ {print $3}' | tr -d '.')
    pages_inactive=$(echo "$vm_stats" | awk '/Pages inactive/ {print $3}' | tr -d '.')
    pages_wired=$(echo "$vm_stats" | awk '/Pages wired down/ {print $4}' | tr -d '.')
    
    mem_free_gb=$(echo "scale=2; $pages_free * $page_size / 1024 / 1024 / 1024" | bc 2>/dev/null)
    mem_used_gb=$(echo "scale=2; ($pages_active + $pages_wired) * $page_size / 1024 / 1024 / 1024" | bc 2>/dev/null)
    
    echo -e "${GREEN}=== Memory Summary ===${NC}"
    echo ""
    printf "%-25s %.2f GB\n" "Used:" "$mem_used_gb"
    printf "%-25s %.2f GB\n" "Free:" "$mem_free_gb"
else
    echo -e "${YELLOW}Memory information not available${NC}"
fi
echo ""

# Swap Information
echo -e "${GREEN}=== Swap Memory ===${NC}"
echo ""

if command -v free &> /dev/null; then
    swap_total=$(free -h | awk '/^Swap:/ {print $2}')
    swap_used=$(free -h | awk '/^Swap:/ {print $3}')
    swap_free=$(free -h | awk '/^Swap:/ {print $4}')
    
    printf "%-25s %s\n" "Total Swap:" "$swap_total"
    printf "%-25s %s\n" "Used Swap:" "$swap_used"
    printf "%-25s %s\n" "Free Swap:" "$swap_free"
    
    swap_total_kb=$(free | awk '/^Swap:/ {print $2}')
    if [ "$swap_total_kb" -gt 0 ]; then
        swap_used_kb=$(free | awk '/^Swap:/ {print $3}')
        swap_percent=$(echo "scale=1; $swap_used_kb * 100 / $swap_total_kb" | bc 2>/dev/null || awk "BEGIN {printf \"%.1f\", $swap_used_kb * 100 / $swap_total_kb}")
        printf "%-25s %.1f%%\n" "Swap Usage:" "$swap_percent"
    fi
elif command -v swapon &> /dev/null; then
    swapon --show 2>/dev/null || echo -e "${YELLOW}No swap configured${NC}"
else
    echo -e "${YELLOW}Swap information not available${NC}"
fi
echo ""

# Memory Details from /proc/meminfo
if [ -f /proc/meminfo ]; then
    echo -e "${GREEN}=== Detailed Memory Information ===${NC}"
    echo ""
    
    printf "${CYAN}%-25s %15s${NC}\n" "METRIC" "VALUE"
    echo "----------------------------------------"
    
    grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapCached|Active|Inactive|Dirty|Writeback|Slab" /proc/meminfo | \
    while IFS=: read -r key value; do
        printf "%-25s %15s\n" "$key" "$(echo $value | xargs)"
    done
fi
echo ""

# Top Memory Consuming Processes
echo -e "${GREEN}=== Top 10 Memory Consuming Processes ===${NC}"
echo ""
printf "${CYAN}%-8s %-10s %-10s %s${NC}\n" "PID" "USER" "MEM%" "COMMAND"
echo "--------------------------------------------------------------------------------"

if command -v ps &> /dev/null; then
    ps aux --sort=-%mem 2>/dev/null | head -11 | tail -10 | awk '{printf "%-8s %-10s %-10s %s\n", $2, $1, $4"%", $11}' || \
    ps aux -m 2>/dev/null | head -11 | tail -10 | awk '{printf "%-8s %-10s %-10s %s\n", $2, $1, $4"%", $11}'
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
