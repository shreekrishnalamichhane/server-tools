#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Network Information${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Network Interfaces
echo -e "${GREEN}=== Network Interfaces ===${NC}"
echo ""

if command -v ip &> /dev/null; then
    ip -br addr show
    echo ""
    
    echo -e "${GREEN}=== Detailed Interface Information ===${NC}"
    echo ""
    ip addr show
elif command -v ifconfig &> /dev/null; then
    ifconfig
else
    echo -e "${YELLOW}Network interface information not available${NC}"
fi
echo ""

# Routing Table
echo -e "${GREEN}=== Routing Table ===${NC}"
echo ""

if command -v ip &> /dev/null; then
    ip route show
elif command -v netstat &> /dev/null; then
    netstat -rn
else
    echo -e "${YELLOW}Routing information not available${NC}"
fi
echo ""

# Network Statistics
echo -e "${GREEN}=== Network Statistics ===${NC}"
echo ""

if [ -f /proc/net/dev ]; then
    printf "${CYAN}%-15s %15s %15s %15s %15s${NC}\n" "INTERFACE" "RX BYTES" "RX PACKETS" "TX BYTES" "TX PACKETS"
    echo "--------------------------------------------------------------------------------"
    
    tail -n +3 /proc/net/dev | while IFS=: read -r interface stats; do
        interface=$(echo "$interface" | xargs)
        read -r rx_bytes rx_packets rx_errs rx_drop _ _ _ _ tx_bytes tx_packets _ <<< "$stats"
        
        # Convert to human readable
        rx_bytes_h=$(numfmt --to=iec-i --suffix=B "$rx_bytes" 2>/dev/null || echo "$rx_bytes")
        tx_bytes_h=$(numfmt --to=iec-i --suffix=B "$tx_bytes" 2>/dev/null || echo "$tx_bytes")
        
        printf "%-15s %15s %15s %15s %15s\n" "$interface" "$rx_bytes_h" "$rx_packets" "$tx_bytes_h" "$tx_packets"
    done
elif command -v netstat &> /dev/null; then
    netstat -i
else
    echo -e "${YELLOW}Network statistics not available${NC}"
fi
echo ""

# Active Connections
echo -e "${GREEN}=== Active Network Connections ===${NC}"
echo ""

if command -v ss &> /dev/null; then
    echo -e "${BLUE}Connection Summary:${NC}"
    echo ""
    printf "%-20s %10s\n" "STATE" "COUNT"
    echo "--------------------------------"
    ss -tan | tail -n +2 | awk '{print $1}' | sort | uniq -c | awk '{printf "%-20s %10s\n", $2, $1}'
    echo ""
    
    echo -e "${BLUE}Listening Ports:${NC}"
    echo ""
    printf "${CYAN}%-10s %-20s %-20s %s${NC}\n" "PROTO" "LOCAL ADDRESS" "REMOTE ADDRESS" "STATE"
    echo "--------------------------------------------------------------------------------"
    ss -tuln | tail -n +2 | awk '{printf "%-10s %-20s %-20s %s\n", $1, $5, $6, $2}'
elif command -v netstat &> /dev/null; then
    echo -e "${BLUE}Connection Summary:${NC}"
    echo ""
    netstat -an | grep ESTABLISHED | wc -l | xargs echo "Established connections:"
    echo ""
    
    echo -e "${BLUE}Listening Ports:${NC}"
    echo ""
    netstat -tuln
else
    echo -e "${YELLOW}Connection information not available${NC}"
fi
echo ""

# DNS Configuration
echo -e "${GREEN}=== DNS Configuration ===${NC}"
echo ""

if [ -f /etc/resolv.conf ]; then
    printf "%-25s %s\n" "DNS Servers:" ""
    grep "^nameserver" /etc/resolv.conf | awk '{printf "  - %s\n", $2}'
    
    domain=$(grep "^domain" /etc/resolv.conf 2>/dev/null | awk '{print $2}')
    search=$(grep "^search" /etc/resolv.conf 2>/dev/null | cut -d' ' -f2-)
    
    [ -n "$domain" ] && printf "%-25s %s\n" "Domain:" "$domain"
    [ -n "$search" ] && printf "%-25s %s\n" "Search domains:" "$search"
else
    echo -e "${YELLOW}DNS configuration not available${NC}"
fi
echo ""

# Network Bandwidth (if available)
if command -v vnstat &> /dev/null; then
    echo -e "${GREEN}=== Network Bandwidth Usage ===${NC}"
    echo ""
    vnstat
    echo ""
fi

# Firewall Status
echo -e "${GREEN}=== Firewall Status ===${NC}"
echo ""

if command -v ufw &> /dev/null; then
    ufw status 2>/dev/null || echo -e "${YELLOW}UFW not configured or requires root${NC}"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --state 2>/dev/null || echo -e "${YELLOW}Firewalld status requires root${NC}"
elif command -v iptables &> /dev/null; then
    iptables -L -n 2>/dev/null | head -20 || echo -e "${YELLOW}iptables requires root access${NC}"
else
    echo -e "${YELLOW}Firewall information not available${NC}"
fi

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
