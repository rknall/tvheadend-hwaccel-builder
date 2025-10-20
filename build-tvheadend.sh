#!/bin/bash
# build-tvheadend.sh - Build TVHeadend Full Debian package

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOCKER_IMAGE="tvheadend-builder-debian"
DOCKERFILE="Dockerfile.debian"
OUTPUT_DIR="./output"
NO_CACHE=""

# Check for --clean flag
if [ "$1" = "--clean" ] || [ "$1" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
    echo -e "${YELLOW}Building without cache (clean build)${NC}"
fi

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}TVHeadend Multi-Package Builder${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Usage: $0 [--clean|--no-cache]"
echo "  --clean: Build without using Docker cache"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker not found${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon not running${NC}"
    exit 1
fi

# Check Dockerfile
if [ ! -f "$DOCKERFILE" ]; then
    echo -e "${RED}Error: $DOCKERFILE not found${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -f "$OUTPUT_DIR"/*.deb "$OUTPUT_DIR"/BUILD_INFO.txt 2>/dev/null || true

# Build Docker image
echo ""
echo -e "${GREEN}Step 1: Building Docker image${NC}"
echo "This will take 20-30 minutes..."
echo ""

if docker build $NO_CACHE -t "$DOCKER_IMAGE" -f "$DOCKERFILE" .; then
    echo -e "${GREEN}✓ Docker image built${NC}"
else
    echo -e "${RED}✗ Failed to build image${NC}"
    exit 1
fi

# Build packages
echo ""
echo -e "${GREEN}Step 2: Building packages${NC}"
echo ""

OUTPUT_ABS=$(cd "$OUTPUT_DIR" && pwd)

if docker run --rm -v "$OUTPUT_ABS:/output" "$DOCKER_IMAGE"; then
    echo -e "${GREEN}✓ Build complete${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Show results
echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Build Complete${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

if [ -f "$OUTPUT_DIR/BUILD_INFO.txt" ]; then
    cat "$OUTPUT_DIR/BUILD_INFO.txt"
fi

echo ""
echo "Packages in: $OUTPUT_ABS"
echo ""
ls -lh "$OUTPUT_DIR"/*.deb 2>/dev/null

echo ""
echo -e "${GREEN}Installation Options:${NC}"
echo ""
echo "  Complete installation (all features):"
echo "    cd $OUTPUT_DIR"
echo "    sudo dpkg -i tvheadend-full_*.deb"
echo "    sudo apt-get install -f"
echo ""
echo "  Core only:"
echo "    sudo dpkg -i tvheadend_*.deb"
echo "    sudo apt-get install -f"
echo ""
echo "  Custom (pick packages you need):"
echo "    sudo dpkg -i tvheadend_*.deb tvheadend-comskip_*.deb"
echo "    sudo apt-get install -f"
echo ""
echo "Start TVHeadend:"
echo "  sudo systemctl start tvheadend"
echo ""
echo "Web interface: http://localhost:9981"
echo ""
