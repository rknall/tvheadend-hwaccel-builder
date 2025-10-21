#!/bin/bash
set -e

# Read build metadata
VERSION=$(cat /build/VERSION.txt)
ARCH=$(cat /build/ARCH.txt)

# Source distro-specific configuration
if [ -f /build/scripts/distro-config.sh ]; then
    source /build/scripts/distro-config.sh
fi

# Copy all packages to output
cp /build/tvheadend_${VERSION}_${ARCH}${PACKAGE_EXT} /output/
cp /build/tvheadend-comskip_${VERSION}_${ARCH}${PACKAGE_EXT} /output/
cp /build/tvheadend-picons_${VERSION}_all${PACKAGE_EXT} /output/
cp /build/tvheadend-webgrab_${VERSION}_all${PACKAGE_EXT} /output/
cp /build/tvheadend-full_${VERSION}_all${PACKAGE_EXT} /output/

# Generate BUILD_INFO from template
cp /build/templates/BUILD_INFO.txt.template /output/BUILD_INFO.txt

# Replace all placeholders
sed -i "s/__BUILD_DATE__/$(date)/g" /output/BUILD_INFO.txt
sed -i "s/__VERSION__/${VERSION}/g" /output/BUILD_INFO.txt
sed -i "s/__ARCH__/${ARCH}/g" /output/BUILD_INFO.txt
sed -i "s/__DISTRO__/${DISTRO}/g" /output/BUILD_INFO.txt
sed -i "s/__DISTRO_BASE__/${DISTRO_BASE}/g" /output/BUILD_INFO.txt
sed -i "s/__PACKAGE_EXT__/${PACKAGE_EXT}/g" /output/BUILD_INFO.txt
sed -i "s/__INSTALL_CMD__/${INSTALL_CMD}/g" /output/BUILD_INFO.txt
sed -i "s|__INSTALL_DEPS_CMD__|${INSTALL_DEPS_CMD}|g" /output/BUILD_INFO.txt
sed -i "s/__TVHEADEND_COMMIT__/__TVHEADEND_COMMIT__/g" /output/BUILD_INFO.txt
sed -i "s/__COMSKIP_COMMIT__/__COMSKIP_COMMIT__/g" /output/BUILD_INFO.txt
sed -i "s/__COMCHAP_COMMIT__/__COMCHAP_COMMIT__/g" /output/BUILD_INFO.txt
sed -i "s/__PICONS_RELEASE__/__PICONS_RELEASE__/g" /output/BUILD_INFO.txt

echo "Build complete! 5 packages created:"
ls -lh /output/*${PACKAGE_EXT}
echo ""
cat /output/BUILD_INFO.txt
