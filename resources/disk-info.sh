#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Disk Information${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Disk Usage by Filesystem
echo -e "${GREEN}=== Disk Usage by Filesystem ===${NC}"
echo ""
df -h | grep -v "tmpfs\|udev\|loop"
echo ""

# Disk Usage Summary
echo -e "${GREEN}=== Disk Usage Summary ===${NC}"
echo ""
total_size=$(df -h | grep -v "tmpfs\|udev\|loop\|Filesystem" | awk '{sum+=$2} END {print sum}')
total_used=$(df -h | grep -v "tmpfs\|udev\|loop\|Filesystem" | awk '{sum+=$3} END {print sum}')
total_avail=$(df -h | grep -v "tmpfs\|udev\|loop\|Filesystem" | awk '{sum+=$4} END {print sum}')

df -h | grep -v "tmpfs\|udev\|loop\|Filesystem" | awk '
{
    total_gb += $2;
    used_gb += $3;
    avail_gb += $4;
}
END {
    if (total_gb > 0) {
        used_percent = (used_gb / total_gb) * 100;
        printf "%-25s %.1f GB\n", "Total Disk Space:", total_gb;
        printf "%-25s %.1f GB (%.1f%%)\n", "Used:", used_gb, used_percent;
        printf "%-25s %.1f GB\n", "Available:", avail_gb;
    }
}'
echo ""

# Inode Usage
echo -e "${GREEN}=== Inode Usage ===${NC}"
echo ""
df -i | grep -v "tmpfs\|udev\|loop"
echo ""

# Disk I/O Statistics
if command -v iostat &> /dev/null; then
    echo -e "${GREEN}=== Disk I/O Statistics ===${NC}"
    echo ""
    iostat -x 2 2 | tail -n +4
    echo ""
fi

# Block Devices
echo -e "${GREEN}=== Block Devices ===${NC}"
echo ""

if command -v lsblk &> /dev/null; then
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
elif command -v diskutil &> /dev/null; then
    # macOS
    diskutil list
else
    echo -e "${YELLOW}Block device information not available${NC}"
fi
echo ""

# Disk Information Details
if [ -d /sys/block ]; then
    echo -e "${GREEN}=== Physical Disk Details ===${NC}"
    echo ""
    
    printf "${CYAN}%-15s %-10s %-15s %-10s${NC}\n" "DEVICE" "SIZE" "TYPE" "REMOVABLE"
    echo "--------------------------------------------------------------------------------"
    
    for disk in /sys/block/sd* /sys/block/nvme* /sys/block/vd* 2>/dev/null; do
        if [ -d "$disk" ]; then
            disk_name=$(basename "$disk")
            disk_size=$(cat "$disk/size" 2>/dev/null)
            
            if [ -n "$disk_size" ] && [ "$disk_size" -gt 0 ]; then
                size_gb=$(echo "scale=2; $disk_size * 512 / 1024 / 1024 / 1024" | bc 2>/dev/null || awk "BEGIN {printf \"%.2f\", $disk_size * 512 / 1024 / 1024 / 1024}")
                removable=$(cat "$disk/removable" 2>/dev/null)
                removable_text="No"
                [ "$removable" = "1" ] && removable_text="Yes"
                
                disk_type="HDD"
                if [ -f "$disk/queue/rotational" ]; then
                    rotational=$(cat "$disk/queue/rotational")
                    [ "$rotational" = "0" ] && disk_type="SSD"
                fi
                
                printf "%-15s %-10s %-15s %-10s\n" "$disk_name" "${size_gb}GB" "$disk_type" "$removable_text"
            fi
        fi
    done
    echo ""
fi

# Mount Points
echo -e "${GREEN}=== Mount Points ===${NC}"
echo ""
mount | grep -v "tmpfs\|udev\|loop" | awk '{printf "%-30s on %-30s type %s\n", $1, $3, $5}'
echo ""

# Top 10 Largest Directories (in root filesystem)
echo -e "${GREEN}=== Top 10 Largest Directories in / ===${NC}"
echo ""
echo -e "${BLUE}Calculating... (this may take a moment)${NC}"
echo ""

if command -v du &> /dev/null; then
    printf "${CYAN}%-10s %s${NC}\n" "SIZE" "DIRECTORY"
    echo "--------------------------------------------------------------------------------"
    du -hx --max-depth=1 / 2>/dev/null | sort -rh | head -11 | tail -10 | awk '{printf "%-10s %s\n", $1, $2}'
else
    echo -e "${YELLOW}Directory size calculation not available${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
