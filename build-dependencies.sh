#!/bin/bash
# Build FFmpeg and libvpl packages before building TVHeadend

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/custom-libs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Detect platform architecture
PLATFORM="${DOCKER_DEFAULT_PLATFORM:-linux/$(uname -m)}"
ARCH=$(echo "$PLATFORM" | cut -d'/' -f2)

echo_info "Building dependency packages for ${ARCH}..."
echo_info "This will take approximately 30-45 minutes"
echo ""

# Build libvpl first (FFmpeg might depend on it) - but only for amd64/Intel
if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ]; then
    echo_info "Step 1/2: Building libvpl 2.15.0 (Intel only)..."
    docker build -t libvpl-builder -f Dockerfile.libvpl .
    docker run --rm -v "${OUTPUT_DIR}:/output" libvpl-builder
    echo ""
    echo_info "Step 2/2: Building FFmpeg 7.1.2..."
else
    echo_warn "Skipping libvpl build (Intel-only, not available for ${ARCH})"
    echo_info "Step 1/1: Building FFmpeg 7.1.2..."
fi

docker build -t ffmpeg-builder -f Dockerfile.ffmpeg .
docker run --rm -v "${OUTPUT_DIR}:/output" ffmpeg-builder

echo ""
echo_info "Dependency packages built successfully!"
echo_info "Output directory: ${OUTPUT_DIR}"
echo ""
echo_info "Built packages:"
ls -lh "${OUTPUT_DIR}"/*.deb 2>/dev/null || echo_warn "No .deb files found"

echo ""
echo_info "You can now run ./build-tvheadend.sh to build TVHeadend with these packages"
