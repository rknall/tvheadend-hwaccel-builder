# Dockerfile Refactoring - External Templates

## Overview

This document describes the refactoring of heredoc content from Dockerfile.debian into external, reusable template files. This makes the build system more maintainable and easily adaptable for other Linux distributions.

## Changes Made

### 1. Created External Template Files

#### `templates/webgrab-config.xml.template`
- Extracted the WebGrab++ XML configuration from inline echo statements
- Makes it easier to modify WebGrab++ default settings
- Cleaner and more maintainable than shell echo commands

#### `templates/BUILD_INFO.txt.template`
- Extracted the large BUILD_INFO.txt heredoc into a template file
- Uses placeholder variables that get replaced at build time:
  - `__DISTRO__` - Distribution name (e.g., "Debian", "Ubuntu")
  - `__DISTRO_BASE__` - Base version info (e.g., "Debian Base: bookworm")
  - `__VERSION__` - Package version
  - `__ARCH__` - Architecture (amd64, arm64)
  - `__PACKAGE_EXT__` - Package extension (.deb, .rpm, etc.)
  - `__INSTALL_CMD__` - Install command (dpkg -i, dnf install, etc.)
  - `__INSTALL_DEPS_CMD__` - Dependency install command
  - `__BUILD_DATE__` - Build timestamp
  - `__TVHEADEND_COMMIT__` - TVHeadend git commit
  - `__COMSKIP_COMMIT__` - Comskip git commit
  - `__COMCHAP_COMMIT__` - Comchap git commit
  - `__PICONS_RELEASE__` - Picons release tag

### 2. Created Modular Scripts

#### `scripts/distro-config.sh`
- Contains distribution-specific configuration
- Sets variables like:
  - `DISTRO` - Distribution name
  - `DISTRO_BASE` - Base version description
  - `PACKAGE_EXT` - Package file extension
  - `INSTALL_CMD` - Package install command
  - `INSTALL_DEPS_CMD` - Dependency resolution command
- Includes commented examples for Ubuntu, Fedora, and Arch Linux
- Can be customized in Dockerfile for each distribution

#### `scripts/copy-output.sh`
- Extracted from large heredoc in Dockerfile
- Sources `distro-config.sh` for distribution settings
- Copies built packages to output directory
- Generates BUILD_INFO.txt from template with variable substitution
- Generic and reusable across distributions

### 3. Updated Dockerfile.debian

The Dockerfile now:
1. Copies external files early in build:
   ```dockerfile
   COPY debian/ ${BUILD_DIR}/debian/
   COPY templates/ ${BUILD_DIR}/templates/
   COPY scripts/ ${BUILD_DIR}/scripts/
   ```

2. Uses the WebGrab++ template instead of echo statements:
   ```dockerfile
   cp ${BUILD_DIR}/templates/webgrab-config.xml.template webgrab/.wg++/WebGrab++.config.xml
   ```

3. Configures distro-specific settings:
   ```dockerfile
   RUN sed -i "s|^DISTRO=.*|DISTRO=\"Debian\"|g" ${BUILD_DIR}/scripts/distro-config.sh
   ```

4. Substitutes build-time values into scripts:
   ```dockerfile
   RUN sed -i "s/__TVHEADEND_COMMIT__/${TVHEADEND_COMMIT}/g" ${BUILD_DIR}/scripts/copy-output.sh
   ```

5. Uses the external script as CMD:
   ```dockerfile
   CMD ["/build/scripts/copy-output.sh"]
   ```

## Benefits

### Maintainability
- Templates are easier to read and edit than heredocs or echo statements
- Changes to BUILD_INFO format don't require Dockerfile modifications
- Syntax highlighting works properly in template files

### Reusability
- Same templates can be used across different distributions
- Only need to change distro-config.sh for new distributions
- Reduces code duplication

### Flexibility
- Easy to add new placeholders to templates
- Distribution-specific customization is centralized
- Can create Dockerfile.ubuntu, Dockerfile.fedora, etc. that reuse the same templates

### Testing
- Templates can be validated independently
- Scripts can be tested outside of Docker
- Easier to debug issues in isolated files

## Future Distribution Support

To add support for a new distribution (e.g., Ubuntu, Fedora):

1. **Create new Dockerfile** (e.g., `Dockerfile.ubuntu`):
   ```dockerfile
   FROM ubuntu:jammy AS builder
   # ... install dependencies for Ubuntu ...
   COPY debian/ ${BUILD_DIR}/debian/
   COPY templates/ ${BUILD_DIR}/templates/
   COPY scripts/ ${BUILD_DIR}/scripts/
   # ... build steps ...

   # Configure for Ubuntu
   RUN sed -i "s|^DISTRO=.*|DISTRO=\"Ubuntu\"|g" ${BUILD_DIR}/scripts/distro-config.sh && \
       sed -i "s|^DISTRO_BASE=.*|DISTRO_BASE=\"Ubuntu Base: jammy\"|g" ${BUILD_DIR}/scripts/distro-config.sh
   ```

2. **Reuse existing templates** - No changes needed!

3. **Reuse existing scripts** - No changes needed!

4. **Only customize**:
   - Package dependencies in Dockerfile
   - Distribution name/base in distro-config.sh
   - Package build commands if needed (dpkg vs rpm)

## File Structure

```
TVHBuilder/
├── Dockerfile.debian          # Debian-specific Dockerfile
├── debian/                    # Debian package control files
│   ├── control-*.template     # Package metadata templates
│   ├── postinst*              # Post-install scripts
│   ├── postrm*               # Post-removal scripts
│   └── systemd/              # Systemd service files
├── templates/                 # NEW: Reusable templates
│   ├── webgrab-config.xml.template
│   └── BUILD_INFO.txt.template
├── scripts/                   # NEW: Reusable scripts
│   ├── distro-config.sh      # Distribution configuration
│   └── copy-output.sh        # Output generation script
└── output/                    # Build output directory
```

## Migration Summary

| Before | After | Benefit |
|--------|-------|---------|
| Heredoc in Dockerfile (85 lines) | `templates/BUILD_INFO.txt.template` | Easier to edit, syntax highlighting |
| Echo statements (12 lines) | `templates/webgrab-config.xml.template` | XML validation, cleaner |
| Inline shell script | `scripts/copy-output.sh` | Testable, reusable |
| Hardcoded distro settings | `scripts/distro-config.sh` | Centralized, documented |

## Testing

To verify the changes work correctly:

```bash
# Build with new structure
./build-tvheadend.sh --clean

# Check that all templates were processed
ls -lh output/
cat output/BUILD_INFO.txt

# Verify BUILD_INFO contains correct values (no __PLACEHOLDER__ strings)
grep -E "__(VERSION|ARCH|DISTRO)__" output/BUILD_INFO.txt
# Should return no matches

# Verify packages were created
ls -lh output/*.deb
```

## Backward Compatibility

This refactoring maintains 100% backward compatibility:
- Output packages are identical
- BUILD_INFO.txt format is unchanged
- Installation process is identical
- No user-facing changes
