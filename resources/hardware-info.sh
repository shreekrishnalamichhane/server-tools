#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Hardware Information${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# System Information
echo -e "${GREEN}=== System Information ===${NC}"
echo ""

if command -v dmidecode &> /dev/null; then
    # Requires root
    manufacturer=$(dmidecode -s system-manufacturer 2>/dev/null)
    product=$(dmidecode -s system-product-name 2>/dev/null)
    serial=$(dmidecode -s system-serial-number 2>/dev/null)
    uuid=$(dmidecode -s system-uuid 2>/dev/null)
    
    [ -n "$manufacturer" ] && printf "%-25s %s\n" "Manufacturer:" "$manufacturer"
    [ -n "$product" ] && printf "%-25s %s\n" "Product:" "$product"
    [ -n "$serial" ] && printf "%-25s %s\n" "Serial Number:" "$serial"
    [ -n "$uuid" ] && printf "%-25s %s\n" "UUID:" "$uuid"
    
    if [ -z "$manufacturer" ]; then
        echo -e "${YELLOW}Run with sudo for detailed hardware info${NC}"
    fi
else
    printf "%-25s %s\n" "Hostname:" "$(hostname)"
    printf "%-25s %s\n" "Kernel:" "$(uname -r)"
fi
echo ""

# CPU Information
echo -e "${GREEN}=== CPU Information ===${NC}"
echo ""

if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
    cpu_sockets=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l | tr -d ' ')
    
    printf "%-25s %s\n" "Model:" "$cpu_model"
    printf "%-25s %s\n" "Physical CPUs:" "$cpu_sockets"
    printf "%-25s %s\n" "Total Cores:" "$cpu_cores"
    
    if grep -q "flags" /proc/cpuinfo; then
        flags=$(grep -m1 "flags" /proc/cpuinfo | cut -d: -f2)
        echo ""
        echo -e "${BLUE}CPU Features:${NC}"
        echo "$flags" | grep -o "\b[a-z0-9_]*\b" | head -20 | column
    fi
elif command -v sysctl &> /dev/null; then
    cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null)
    
    [ -n "$cpu_model" ] && printf "%-25s %s\n" "Model:" "$cpu_model"
    [ -n "$cpu_cores" ] && printf "%-25s %s\n" "CPU Cores:" "$cpu_cores"
fi
echo ""

# Memory Information
echo -e "${GREEN}=== Memory Information ===${NC}"
echo ""

if command -v dmidecode &> /dev/null; then
    mem_devices=$(dmidecode -t memory 2>/dev/null | grep -c "Memory Device")
    if [ "$mem_devices" -gt 0 ]; then
        dmidecode -t memory 2>/dev/null | grep -E "Size|Speed|Type:|Manufacturer" | grep -v "No Module\|Unknown" | head -20
    fi
    
    if [ -z "$(dmidecode -t memory 2>/dev/null | grep Size)" ]; then
        if command -v free &> /dev/null; then
            free -h | grep "^Mem:"
        fi
    fi
else
    if command -v free &> /dev/null; then
        free -h | grep "^Mem:"
    elif [ -f /proc/meminfo ]; then
        grep "MemTotal" /proc/meminfo
    fi
fi
echo ""

# Storage Devices
echo -e "${GREEN}=== Storage Devices ===${NC}"
echo ""

if command -v lsblk &> /dev/null; then
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
elif command -v diskutil &> /dev/null; then
    diskutil list
else
    df -h | grep -v "tmpfs\|udev\|loop"
fi
echo ""

# PCI Devices
if command -v lspci &> /dev/null; then
    echo -e "${GREEN}=== PCI Devices ===${NC}"
    echo ""
    lspci | head -20
    echo ""
    echo -e "${BLUE}Use 'lspci -v' for detailed information${NC}"
    echo ""
fi

# USB Devices
if command -v lsusb &> /dev/null; then
    echo -e "${GREEN}=== USB Devices ===${NC}"
    echo ""
    lsusb
    echo ""
fi

# Network Adapters
echo -e "${GREEN}=== Network Adapters ===${NC}"
echo ""

if command -v ip &> /dev/null; then
    ip link show | grep -E "^[0-9]" | awk '{print $2, $3}'
elif command -v ifconfig &> /dev/null; then
    ifconfig | grep -E "^[a-z]" | awk '{print $1}'
fi
echo ""

# Graphics/Video
if command -v lspci &> /dev/null; then
    echo -e "${GREEN}=== Graphics Controller ===${NC}"
    echo ""
    lspci | grep -i "vga\|3d\|display" || echo -e "${YELLOW}No graphics controller detected${NC}"
    echo ""
fi

# BIOS Information
if command -v dmidecode &> /dev/null; then
    echo -e "${GREEN}=== BIOS Information ===${NC}"
    echo ""
    bios_vendor=$(dmidecode -s bios-vendor 2>/dev/null)
    bios_version=$(dmidecode -s bios-version 2>/dev/null)
    bios_date=$(dmidecode -s bios-release-date 2>/dev/null)
    
    [ -n "$bios_vendor" ] && printf "%-25s %s\n" "BIOS Vendor:" "$bios_vendor"
    [ -n "$bios_version" ] && printf "%-25s %s\n" "BIOS Version:" "$bios_version"
    [ -n "$bios_date" ] && printf "%-25s %s\n" "Release Date:" "$bios_date"
    
    if [ -z "$bios_vendor" ]; then
        echo -e "${YELLOW}Run with sudo for BIOS information${NC}"
    fi
    echo ""
fi

# Hardware Summary
echo -e "${GREEN}=== Hardware Summary ===${NC}"
echo ""

if command -v inxi &> /dev/null; then
    inxi -F
elif command -v lshw &> /dev/null; then
    echo -e "${BLUE}Full hardware tree available with: sudo lshw${NC}"
else
    echo -e "${YELLOW}Install 'inxi' or 'lshw' for detailed hardware summary${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
