#!/bin/bash
#
# TVHeadend Full - Complete Cleanup Script
#
# This script fully removes TVHeadend Full installation including:
# - Service files
# - Binaries and libraries
# - Configuration directories
# - User and group
# - Package registration
#
# Safe to run multiple times - includes failsafes for missing components
#

set +e  # Don't exit on errors - we want to clean up as much as possible

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

HTS_USER="hts"
PACKAGE_NAME="tvheadend-full"

echo "========================================"
echo "TVHeadend Full - Complete Cleanup"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}WARNING: This will completely remove TVHeadend Full and all its data!${NC}"
echo "This includes:"
echo "  - Service and binaries"
echo "  - All recordings"
echo "  - All configuration"
echo "  - User account and home directory"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi
echo ""

# Function to safely execute commands
safe_exec() {
    local description="$1"
    shift
    echo -n "  $description... "
    if "$@" 2>/dev/null; then
        echo -e "${GREEN}done${NC}"
        return 0
    else
        echo -e "${YELLOW}skipped${NC}"
        return 1
    fi
}

# 1. Stop and disable systemd service
echo "[1/10] Stopping TVHeadend service"
if systemctl is-active --quiet tvheadend.service 2>/dev/null; then
    safe_exec "Stopping service" systemctl stop tvheadend.service
else
    echo "  Service not running - skipped"
fi

if systemctl is-enabled --quiet tvheadend.service 2>/dev/null; then
    safe_exec "Disabling service" systemctl disable tvheadend.service
else
    echo "  Service not enabled - skipped"
fi

# 2. Remove systemd service file
echo "[2/10] Removing systemd service files"
if [ -f /lib/systemd/system/tvheadend.service ]; then
    safe_exec "Removing service file" rm -f /lib/systemd/system/tvheadend.service
    safe_exec "Reloading systemd" systemctl daemon-reload
else
    echo "  Service file not found - skipped"
fi

# 3. Remove package if installed
echo "[3/10] Removing Debian package"
if dpkg -l | grep -q "^ii.*$PACKAGE_NAME" 2>/dev/null; then
    safe_exec "Purging package" apt-get remove --purge -y "$PACKAGE_NAME"
else
    echo "  Package not installed - skipped"
fi

# 4. Remove binaries
echo "[4/10] Removing binaries"
BINARIES=(
    "/usr/bin/tvheadend"
    "/usr/bin/comskip"
    "/usr/bin/comchap"
    "/usr/bin/comcut"
    "/usr/bin/tv_grab_wg++"
)

for binary in "${BINARIES[@]}"; do
    if [ -f "$binary" ]; then
        safe_exec "Removing $(basename "$binary")" rm -f "$binary"
    fi
done

if [ ${#BINARIES[@]} -eq 0 ] || ! ls "${BINARIES[@]}" >/dev/null 2>&1; then
    echo "  No binaries found - skipped"
fi

# 5. Remove configuration directories
echo "[5/10] Removing configuration directories"
CONFIG_DIRS=(
    "/etc/tvheadend"
    "/etc/comskip"
    "/etc/default/tvheadend"
)

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -e "$dir" ]; then
        safe_exec "Removing $(basename "$dir")" rm -rf "$dir"
    fi
done

# 6. Remove data and log directories
echo "[6/10] Removing data and log directories"
DATA_DIRS=(
    "/var/lib/tvheadend"
    "/var/log/tvheadend"
)

for dir in "${DATA_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        safe_exec "Removing $(basename "$dir")" rm -rf "$dir"
    fi
done

# 7. Remove additional tools
echo "[7/10] Removing additional tools"
TOOL_DIRS=(
    "/opt/picons"
    "/opt/webgrab"
)

for dir in "${TOOL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        safe_exec "Removing $(basename "$dir")" rm -rf "$dir"
    fi
done

# 8. Remove user from groups
echo "[8/10] Removing user from groups"
if getent passwd "$HTS_USER" >/dev/null 2>&1; then
    for group in audio video render; do
        if getent group "$group" >/dev/null 2>&1 && groups "$HTS_USER" 2>/dev/null | grep -q "\b$group\b"; then
            safe_exec "Removing from $group group" gpasswd -d "$HTS_USER" "$group"
        fi
    done
else
    echo "  User $HTS_USER does not exist - skipped"
fi

# 9. Remove user and group
echo "[9/10] Removing user and group"
if getent passwd "$HTS_USER" >/dev/null 2>&1; then
    safe_exec "Removing user $HTS_USER" deluser --remove-home "$HTS_USER"
else
    echo "  User $HTS_USER does not exist - skipped"
fi

if getent group "$HTS_USER" >/dev/null 2>&1; then
    safe_exec "Removing group $HTS_USER" delgroup "$HTS_USER"
else
    echo "  Group $HTS_USER does not exist - skipped"
fi

# 10. Clean up debconf database
echo "[10/10] Cleaning up debconf database"
if command -v debconf-communicate >/dev/null 2>&1; then
    echo "PURGE" | debconf-communicate tvheadend >/dev/null 2>&1 || true
    echo "  Debconf entries purged"
else
    echo "  Debconf not available - skipped"
fi

# Final cleanup
echo ""
echo "Running final cleanup..."
safe_exec "Cleaning package cache" apt-get autoremove -y
safe_exec "Updating package lists" apt-get autoclean

echo ""
echo "========================================"
echo -e "${GREEN}Cleanup complete!${NC}"
echo "========================================"
echo ""
echo "TVHeadend Full has been completely removed from the system."
echo "All data, recordings, and configuration have been deleted."
echo ""
