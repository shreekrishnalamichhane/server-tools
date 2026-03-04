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
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg lsb-release
            
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            echo ""
            echo -e "${GREEN}Docker installed successfully!${NC}"
            echo ""
            echo "Adding current user to docker group..."
            sudo usermod -aG docker $USER
            echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
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
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            
            echo ""
            echo -e "${GREEN}Docker installed successfully!${NC}"
            echo ""
            echo "Adding current user to docker group..."
            sudo usermod -aG docker $USER
            echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
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
