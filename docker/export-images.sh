#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    Export Docker Images${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if ! docker ps &> /dev/null; then
    echo -e "${RED}Docker is not running or not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to menu...${NC}"
    read
    exit 1
fi

# List available images
echo -e "${GREEN}Available Docker Images:${NC}"
echo ""
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
echo ""

# Export options
echo -e "${BLUE}Export Options:${NC}"
echo "  1. Export a single image"
echo "  2. Export all images"
echo "  3. Export multiple selected images"
echo "  0. Cancel"
echo ""
echo -e -n "${BLUE}Select an option: ${NC}"
read -r choice

case $choice in
    1)
        echo ""
        echo -e -n "${BLUE}Enter image name (repository:tag or image ID): ${NC}"
        read -r image_name
        
        if [ -z "$image_name" ]; then
            echo -e "${RED}✗ Image name cannot be empty.${NC}"
        else
            # Sanitize filename
            safe_name=$(echo "$image_name" | sed 's/[\/:]/_/g')
            output_file="${safe_name}.tar"
            
            echo ""
            echo -e "${YELLOW}Exporting ${image_name} to ${output_file}...${NC}"
            
            if docker save -o "$output_file" "$image_name" 2>&1; then
                echo -e "${GREEN}✓ Image exported successfully to ${output_file}${NC}"
                echo -e "File size: $(du -h "$output_file" | cut -f1)"
            else
                echo -e "${RED}✗ Failed to export image. Check if image exists.${NC}"
            fi
        fi
        ;;
    
    2)
        echo ""
        echo -e -n "${BLUE}Enter output filename (default: all-images.tar): ${NC}"
        read -r output_file
        output_file=${output_file:-all-images.tar}
        
        echo ""
        echo -e "${YELLOW}Exporting all images to ${output_file}...${NC}"
        echo -e "${YELLOW}This may take a while...${NC}"
        
        images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
        
        if [ -z "$images" ]; then
            echo -e "${RED}✗ No images found to export.${NC}"
        elif docker save -o "$output_file" $images 2>&1; then
            echo -e "${GREEN}✓ All images exported successfully to ${output_file}${NC}"
            echo -e "File size: $(du -h "$output_file" | cut -f1)"
        else
            echo -e "${RED}✗ Failed to export images.${NC}"
        fi
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}Enter image names separated by spaces (repository:tag or image ID):${NC}"
        read -r images
        
        if [ -z "$images" ]; then
            echo -e "${RED}✗ No images specified.${NC}"
        else
            echo ""
            echo -e -n "${BLUE}Enter output filename (default: selected-images.tar): ${NC}"
            read -r output_file
            output_file=${output_file:-selected-images.tar}
            
            echo ""
            echo -e "${YELLOW}Exporting images to ${output_file}...${NC}"
            
            if docker save -o "$output_file" $images 2>&1; then
                echo -e "${GREEN}✓ Images exported successfully to ${output_file}${NC}"
                echo -e "File size: $(du -h "$output_file" | cut -f1)"
            else
                echo -e "${RED}✗ Failed to export images. Check if all images exist.${NC}"
            fi
        fi
        ;;
    
    0)
        echo -e "${YELLOW}Export cancelled.${NC}"
        ;;
    
    *)
        echo -e "${RED}Invalid option.${NC}"
        ;;
esac

echo ""
echo -e "${CYAN}=== Import Instructions ===${NC}"
echo -e "To import these images on another system, use:"
echo -e "${GREEN}docker load -i <filename.tar>${NC}"

echo ""
echo -e "${YELLOW}Press Enter to return to menu...${NC}"
read
