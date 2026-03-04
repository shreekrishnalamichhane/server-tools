#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Install Docker & Related Tools${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Detect if running as root
SUDO_CMD=""
if [ "$EUID" -ne 0 ]; then
    if command -v sudo &> /dev/null; then
        SUDO_CMD="sudo"
        echo -e "${YELLOW}Running with sudo privileges${NC}"
    else
        echo -e "${RED}This script requires root privileges but sudo is not available.${NC}"
        echo -e "${YELLOW}Please run as root or install sudo.${NC}"
        echo ""
        echo -e "${YELLOW}Press Enter to return to menu...${NC}"
        read
        exit 1
    fi
else
    echo -e "${GREEN}Running as root${NC}"
fi
echo ""

# Detect OS
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo -e "${BLUE}Detected OS: ${OS}${NC}"
echo ""

case $OS in
    ubuntu|debian)
        echo -e "${GREEN}Installing Docker on Ubuntu/Debian...${NC}"
        echo ""
        echo "This will:"
        echo "  1. Update package index"
        echo "  2. Install dependencies"
        echo "  3. Add Docker's official GPG key"
        echo "  4. Set up Docker repository"
        echo "  5. Install Docker Engine"
        echo ""
        echo -e "${YELLOW}Do you want to continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            echo ""
            echo -e "${BLUE}[1/5] Updating package index...${NC}"
            if ! $SUDO_CMD apt-get update; then
                echo -e "${RED}✗ Failed to update package index${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            echo -e "${GREEN}✓ Package index updated${NC}"
            
            echo ""
            echo -e "${BLUE}[2/5] Installing dependencies...${NC}"
            if ! $SUDO_CMD apt-get install -y ca-certificates curl gnupg lsb-release; then
                echo -e "${RED}✗ Failed to install dependencies${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            echo -e "${GREEN}✓ Dependencies installed${NC}"
            
            echo ""
            echo -e "${BLUE}[3/5] Adding Docker's official GPG key...${NC}"
            $SUDO_CMD mkdir -p /etc/apt/keyrings
            if ! curl -fsSL https://download.docker.com/linux/$OS/gpg | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
                echo -e "${RED}✗ Failed to add Docker GPG key${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            echo -e "${GREEN}✓ GPG key added${NC}"
            
            echo ""
            echo -e "${BLUE}[4/5] Setting up Docker repository...${NC}"
            if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | $SUDO_CMD tee /etc/apt/sources.list.d/docker.list > /dev/null; then
                echo -e "${RED}✗ Failed to setup Docker repository${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            echo -e "${GREEN}✓ Repository configured${NC}"
            
            echo ""
            echo -e "${BLUE}[5/5] Installing Docker Engine...${NC}"
            if ! $SUDO_CMD apt-get update; then
                echo -e "${RED}✗ Failed to update package index${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            
            if ! $SUDO_CMD apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
                echo -e "${RED}✗ Failed to install Docker Engine${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            echo -e "${GREEN}✓ Docker Engine installed${NC}"
            
            echo ""
            echo -e "${GREEN}========================================${NC}"
            echo -e "${GREEN}  Docker installed successfully!${NC}"
            echo -e "${GREEN}========================================${NC}"
            
            if [ "$EUID" -ne 0 ]; then
                echo ""
                echo -e "${BLUE}Adding current user to docker group...${NC}"
                if $SUDO_CMD usermod -aG docker $USER; then
                    echo -e "${GREEN}✓ User added to docker group${NC}"
                    echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
                else
                    echo -e "${YELLOW}⚠ Could not add user to docker group${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}Installation cancelled.${NC}"
        fi
        ;;
    
    macos)
        echo -e "${YELLOW}For macOS, please install Docker Desktop:${NC}"
        echo ""
        echo "1. Visit: https://www.docker.com/products/docker-desktop"
        echo "2. Download Docker Desktop for Mac"
        echo "3. Install the .dmg file"
        echo ""
        echo "Or use Homebrew:"
        echo "  brew install --cask docker"
        ;;
    
    fedora|centos|rhel)
        echo -e "${GREEN}Installing Docker on Fedora/CentOS/RHEL...${NC}"
        echo ""
        echo -e "${YELLOW}Do you want to continue? (y/n): ${NC}"
        read -r confirm
        
        if [[ $confirm == [yY] ]]; then
            echo ""
            echo -e "${BLUE}Installing dependencies...${NC}"
            if ! $SUDO_CMD dnf -y install dnf-plugins-core; then
                echo -e "${RED}✗ Failed to install dependencies${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            
            echo -e "${BLUE}Adding Docker repository...${NC}"
            if ! $SUDO_CMD dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo; then
                echo -e "${RED}✗ Failed to add Docker repository${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            
            echo -e "${BLUE}Installing Docker...${NC}"
            if ! $SUDO_CMD dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
                echo -e "${RED}✗ Failed to install Docker${NC}"
                echo ""
                echo -e "${YELLOW}Press Enter to return to menu...${NC}"
                read
                exit 1
            fi
            
            echo -e "${BLUE}Starting Docker service...${NC}"
            if ! $SUDO_CMD systemctl start docker; then
                echo -e "${RED}✗ Failed to start Docker${NC}"
            else
                echo -e "${GREEN}✓ Docker started${NC}"
            fi
            
            if ! $SUDO_CMD systemctl enable docker; then
                echo -e "${YELLOW}⚠ Could not enable Docker at startup${NC}"
            else
                echo -e "${GREEN}✓ Docker enabled at startup${NC}"
            fi
            
            echo ""
            echo -e "${GREEN}Docker installed successfully!${NC}"
            
            if [ "$EUID" -ne 0 ]; then
                echo ""
                echo -e "${BLUE}Adding current user to docker group...${NC}"
                if $SUDO_CMD usermod -aG docker $USER; then
                    echo -e "${GREEN}✓ User added to docker group${NC}"
                    echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
                else
                    echo -e "${YELLOW}⚠ Could not add user to docker group${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}Installation cancelled.${NC}"
        fi
        ;;
    
    *)
        echo -e "${RED}Unsupported OS or unable to detect OS.${NC}"
        echo ""
        echo "Please visit https://docs.docker.com/engine/install/ for manual installation instructions."
        ;;
esac

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
