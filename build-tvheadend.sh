#!/bin/bash
# build-tvheadend.sh - Build TVHeadend packages or Docker container

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOCKER_IMAGE="tvheadend-builder-debian"
DOCKERFILE="Dockerfile.debian"
OUTPUT_DIR="./output"
NO_CACHE=""
BUILD_DOCKER_CONTAINER=false
DOCKER_CONTAINER_IMAGE="rknall/tvheadend-hwaccel"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --clean|--no-cache)
            NO_CACHE="--no-cache"
            echo -e "${YELLOW}Building without cache (clean build)${NC}"
            ;;
        --docker)
            BUILD_DOCKER_CONTAINER=true
            DOCKERFILE="Dockerfile.docker"
            DOCKER_IMAGE="tvheadend-runtime"
            ;;
        *)
            ;;
    esac
done

echo -e "${GREEN}======================================${NC}"
if [ "$BUILD_DOCKER_CONTAINER" = true ]; then
    echo -e "${GREEN}TVHeadend Docker Container Builder${NC}"
else
    echo -e "${GREEN}TVHeadend Multi-Package Builder${NC}"
fi
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Usage: $0 [OPTIONS]"
echo "  --clean|--no-cache: Build without using Docker cache"
echo "  --docker:           Build Docker container image instead of packages"
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

# Check for custom libraries (only for package builds)
if [ "$BUILD_DOCKER_CONTAINER" = false ]; then
    if [ -d "custom-libs" ] && [ -n "$(ls -A custom-libs/*.deb 2>/dev/null)" ]; then
        echo -e "${YELLOW}Custom libraries detected in custom-libs/${NC}"
        echo "The following custom packages will be bundled:"
        ls -lh custom-libs/*.deb
        echo ""
        echo -e "${YELLOW}Note: FFmpeg and codec libraries will be bundled into tvheadend package${NC}"
        echo ""
    fi
fi

if [ "$BUILD_DOCKER_CONTAINER" = true ]; then
    # Build Docker runtime container
    echo ""
    echo -e "${GREEN}Building Docker runtime container${NC}"
    echo "Image: $DOCKER_CONTAINER_IMAGE"
    echo "This will take 20-30 minutes..."
    echo ""

    if docker build $NO_CACHE -t "$DOCKER_CONTAINER_IMAGE:latest" -f "$DOCKERFILE" .; then
        echo -e "${GREEN}✓ Docker image built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build Docker image${NC}"
        exit 1
    fi

    # Show results
    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}Docker Container Build Complete${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo ""
    echo "Docker image: $DOCKER_CONTAINER_IMAGE:latest"
    echo ""
    docker images "$DOCKER_CONTAINER_IMAGE:latest"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo ""
    echo "  Run TVHeadend container:"
    echo "    docker run -d --name tvheadend \\"
    echo "      -p 9981:9981 -p 9982:9982 \\"
    echo "      -v /path/to/config:/var/lib/tvheadend \\"
    echo "      -v /path/to/recordings:/recordings \\"
    echo "      --device /dev/dri:/dev/dri \\"
    echo "      $DOCKER_CONTAINER_IMAGE:latest"
    echo ""
    echo "  Web interface: http://localhost:9981"
    echo "  Default login: admin/admin (change immediately!)"
    echo ""
else
    # Build Debian packages
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
fi
