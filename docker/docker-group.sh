#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Manage Docker Group (Non-root)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Detect if running as root
SUDO_CMD=""
if [ "$EUID" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
    else
        echo -e "${RED}This script requires root privileges but sudo is not available.${NC}"
        echo -e "${YELLOW}Please run as root.${NC}"
        echo ""
        echo -e "${YELLOW}Press Enter to return to menu...${NC}"
        read
        exit 1
    fi
fi

# Check if docker group exists
if getent group docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker group exists${NC}"
    echo ""
else
    echo -e "${YELLOW}Docker group does not exist.${NC}"
    echo ""
    echo -e "${BLUE}Creating docker group...${NC}"
    if $SUDO_CMD groupadd docker 2>&1; then
        echo -e "${GREEN}✓ Docker group created${NC}"
    else
        echo -e "${RED}✗ Failed to create docker group${NC}"
        echo ""
        echo -e "${YELLOW}Press Enter to return to menu...${NC}"
        read
        exit 1
    fi
    echo ""
fi

# Show current members of docker group
echo -e "${BLUE}Current members of docker group:${NC}"
docker_members=$(getent group docker | cut -d: -f4)
if [ -z "$docker_members" ]; then
    echo -e "${YELLOW}  (none)${NC}"
else
    echo -e "${GREEN}  $docker_members${NC}"
fi
echo ""

# Display all users on the system (excluding system users)
echo -e "${BLUE}Available users on system:${NC}"
echo ""
printf "${CYAN}%-20s %-10s %-40s${NC}\n" "USERNAME" "UID" "HOME DIRECTORY"
echo "--------------------------------------------------------------------------------"

# Get users with UID >= 1000 (regular users) or UID = 0 (root)
while IFS=: read -r username _ uid _ _ home _; do
    if [ "$uid" -ge 1000 ] || [ "$uid" -eq 0 ]; then
        # Check if user is already in docker group
        in_group=""
        if groups "$username" 2>/dev/null | grep -q "\bdocker\b"; then
            in_group="${GREEN}[IN GROUP]${NC}"
        fi
        printf "%-20s %-10s %-40s %b\n" "$username" "$uid" "$home" "$in_group"
    fi
done < /etc/passwd
echo ""

# Menu options
echo -e "${GREEN}Options:${NC}"
echo ""
echo "  1. Add user to docker group"
echo "  2. Remove user from docker group"
echo "  3. Test docker access (run hello-world)"
echo "  4. Activate group changes (newgrp docker)"
echo "  0. Back to menu"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e -n "${BLUE}Enter username to add to docker group: ${NC}"
        read -r username
        
        if [ -z "$username" ]; then
            echo -e "${RED}✗ Username cannot be empty.${NC}"
        elif ! id "$username" &> /dev/null; then
            echo -e "${RED}✗ User '$username' does not exist.${NC}"
        elif groups "$username" | grep -q "\bdocker\b"; then
            echo -e "${YELLOW}User '$username' is already in docker group.${NC}"
        else
            echo ""
            echo -e "${YELLOW}Adding user '$username' to docker group...${NC}"
            if $SUDO_CMD usermod -aG docker "$username" 2>&1; then
                echo -e "${GREEN}✓ User '$username' added to docker group${NC}"
                echo ""
                echo -e "${CYAN}========================================${NC}"
                echo -e "${CYAN}  Important: Next Steps${NC}"
                echo -e "${CYAN}========================================${NC}"
                echo ""
                if [ "$username" = "$USER" ]; then
                    echo -e "${YELLOW}You added yourself to the docker group.${NC}"
                    echo ""
                    echo -e "To activate the changes, you can either:"
                    echo -e "  1. ${GREEN}Log out and log back in${NC} (recommended)"
                    echo -e "  2. ${GREEN}Restart your system${NC} (if in a VM)"
                    echo -e "  3. ${GREEN}Run: newgrp docker${NC} (temporary for this session)"
                    echo ""
                    echo -e "${BLUE}After that, verify with:${NC} docker run hello-world"
                else
                    echo -e "User '$username' needs to:"
                    echo -e "  1. ${GREEN}Log out and log back in${NC}"
                    echo -e "  2. ${GREEN}Verify with:${NC} docker run hello-world"
                fi
            else
                echo -e "${RED}✗ Failed to add user to docker group${NC}"
            fi
        fi
        ;;
    
    2)
        echo ""
        echo -e -n "${BLUE}Enter username to remove from docker group: ${NC}"
        read -r username
        
        if [ -z "$username" ]; then
            echo -e "${RED}✗ Username cannot be empty.${NC}"
        elif ! id "$username" &> /dev/null; then
            echo -e "${RED}✗ User '$username' does not exist.${NC}"
        elif ! groups "$username" | grep -q "\bdocker\b"; then
            echo -e "${YELLOW}User '$username' is not in docker group.${NC}"
        else
            echo ""
            echo -e "${YELLOW}Removing user '$username' from docker group...${NC}"
            if $SUDO_CMD gpasswd -d "$username" docker 2>&1; then
                echo -e "${GREEN}✓ User '$username' removed from docker group${NC}"
                echo ""
                echo -e "${YELLOW}User needs to log out and log back in for changes to take effect.${NC}"
            else
                echo -e "${RED}✗ Failed to remove user from docker group${NC}"
            fi
        fi
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}Testing Docker access (running hello-world)...${NC}"
        echo ""
        echo -e "${CYAN}========================================${NC}"
        if docker run hello-world 2>&1; then
            echo -e "${CYAN}========================================${NC}"
            echo ""
            echo -e "${GREEN}✓ Docker is working without sudo!${NC}"
        else
            echo -e "${CYAN}========================================${NC}"
            echo ""
            echo -e "${RED}✗ Docker test failed${NC}"
            echo ""
            if ! groups | grep -q "\bdocker\b"; then
                echo -e "${YELLOW}You are not in the docker group yet.${NC}"
                echo -e "Run option 1 to add yourself, then log out/in."
            else
                echo -e "${YELLOW}You are in docker group but changes may not be active.${NC}"
                echo -e "Try logging out and back in, or run: newgrp docker"
            fi
        fi
        ;;
    
    4)
        echo ""
        if ! groups | grep -q "\bdocker\b"; then
            echo -e "${RED}✗ You are not in the docker group yet.${NC}"
            echo -e "${YELLOW}Please add yourself to the group first (option 1).${NC}"
        else
            echo -e "${BLUE}Activating docker group for current session...${NC}"
            echo ""
            echo -e "${YELLOW}Note: This will start a new shell session.${NC}"
            echo -e "${YELLOW}Type 'exit' to return to this menu.${NC}"
            echo ""
            echo -e "${GREEN}Executing: newgrp docker${NC}"
            echo ""
            sleep 2
            newgrp docker
        fi
        ;;
    
    0)
        echo -e "${YELLOW}Returning to menu...${NC}"
        ;;
    
    *)
        echo -e "${RED}✗ Invalid option.${NC}"
        ;;
esac

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
