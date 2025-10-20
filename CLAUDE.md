# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TVHeadend Full is a Debian package builder that creates a comprehensive TV streaming solution. It packages TVHeadend along with commercial detection tools (Comskip, Comchap, Comcut), channel icons (Picons), and EPG grabber (WebGrab++). The build process uses Docker to compile from source and create a .deb package with hardware acceleration support (VAAPI, NVENC, QSV, VDPAU).

**Architecture Support:** The build automatically detects the host architecture (amd64 or arm64) and creates the appropriate package for that platform.

## Build Commands

### Standard Build
```bash
chmod +x build-tvheadend.sh
./build-tvheadend.sh
```

### Clean Build (no cache)
```bash
./build-tvheadend.sh --clean
# or
./build-tvheadend.sh --no-cache
```

### Manual Build Steps
```bash
# Build Docker image
docker build -t tvheadend-builder-debian -f Dockerfile.debian .

# Run build container
mkdir -p output
docker run --rm -v "$(pwd)/output:/output" tvheadend-builder-debian

# Install the package
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f
```

**Build time:** 25-35 minutes (20-25 min for Docker image, 5-10 min for package)

## Architecture

### Build Process Flow
1. **Dockerfile.debian** - Multi-stage Docker build that:
   - Compiles TVHeadend from source (commit: 7de8bf4826b1847118f3a42556cf0afeee2a5912)
   - Compiles Comskip from source (commit: a140b6ac8bc8f596729e9052819affc779c3b377)
   - Downloads Comchap/Comcut scripts (commit: dd7db30c258e965f282ac78825971dd0703a031e)
   - Downloads Picons channel icons (release: 2025-10-17--08-28-59)
   - Downloads WebGrab++ EPG grabber (v5.3.0)
   - Assembles everything into a .deb package structure

2. **build-tvheadend.sh** - Wrapper script that:
   - Validates Docker environment
   - Builds the Docker image
   - Runs the container to generate the .deb package
   - Outputs package to `./output/` directory

### Package Structure
The built Debian package installs to:
- `/usr/bin/` - Binaries (tvheadend, comskip, comchap, comcut, tv_grab_wg++)
- `/etc/tvheadend/` - TVHeadend configuration
- `/etc/comskip/` - Comskip configuration
- `/etc/default/tvheadend` - Default configuration (user, group, options)
- `/var/lib/tvheadend/` - Data, recordings, WebGrab++ output, and superuser file
- `/opt/picons/` - Channel icons (SNP and SRP formats)
- `/opt/webgrab/.wg++/` - WebGrab++ installation
- `/lib/systemd/system/tvheadend.service` - Systemd service file

**User Configuration:**
- Service runs as user `hts` with group `video`
- User is added to `audio`, `video`, and `render` groups for hardware access
- Default admin credentials: username `admin`, password `admin` (stored in `/var/lib/tvheadend/superuser`)

### Hardware Acceleration Architecture
The package is built with support for multiple hardware acceleration methods:
- **VAAPI** - Intel/AMD GPU acceleration (via libva-dev, libva-drm2)
- **NVENC** - NVIDIA GPU encoding (--enable-nvenc)
- **QSV** - Intel Quick Sync Video (--enable-qsv)
- **VDPAU** - NVIDIA video decoding

The postinst script automatically adds the `tvheadend` user to `audio`, `video`, and `render` groups for GPU access.

## Component Versions

When updating component versions, modify these ARG variables in Dockerfile.debian:
- `TVHEADEND_COMMIT` - Git commit hash from tvheadend/tvheadend
- `COMSKIP_COMMIT` - Git commit hash from erikkaashoek/Comskip
- `COMCHAP_COMMIT` - Git commit hash from BrettSheleski/comchap
- `PICONS_RELEASE` - Release tag from picons/picons

## Package Maintenance Scripts

The Dockerfile creates package maintenance scripts matching the official TVHeadend package structure:

1. **postinst** - Post-installation script:
   - Creates `hts` user and group (matching official package)
   - Adds user to audio/video/render groups for hardware access
   - Creates directories with correct permissions
   - **Creates `/var/lib/tvheadend/superuser` file** with default admin/admin credentials
   - Enables systemd service

2. **prerm** - Pre-removal script:
   - Stops and disables systemd service

3. **postrm** - Post-removal script:
   - On purge: removes user, group, and config directories
   - Cleans up symlinks

4. **control** - Package metadata:
   - Dependencies list (libavahi, libavcodec, libva, etc.)
   - Recommends ffmpeg, streamlink, hardware drivers
   - Package description and version

5. **/etc/default/tvheadend** - Default configuration:
   - Sets `OPTIONS="-u hts -g video"`
   - Used by systemd service via `EnvironmentFile`

## Docker Specifics

- Base image: `debian:bookworm`
- Build directory: `/build` (inside container)
- Output directory: `/output` (mounted from host)
- The Dockerfile uses multi-stage build patterns with all compilation in one stage
- ccache is available to speed up rebuilds

## Testing the Package

After building, test on a Debian/Ubuntu system:
```bash
# Install
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f

# Start service
sudo systemctl start tvheadend
sudo systemctl status tvheadend

# Check logs
sudo journalctl -u tvheadend -f

# Access web UI
# Open http://localhost:9981
```

## Common Development Tasks

### Modifying TVHeadend Build Configuration
Edit the `./configure` flags in Dockerfile.debian at line 42. Key flags:
- `--enable-*` / `--disable-*` - Enable/disable features
- `--enable-bundle` - Bundle web interface
- Hardware acceleration flags: `--enable-vaapi`, `--enable-nvenc`, `--enable-qsv`

### Adding New Dependencies
Add to the `apt-get install` section at line 17-27 in Dockerfile.debian, then add runtime dependencies to the `Depends:` or `Recommends:` line in the control file (line 140).

### Debugging Build Failures
```bash
# Build with no cache to ensure clean build
./build-tvheadend.sh --clean

# Check Docker logs
docker logs <container-id>

# Inspect the builder image
docker run -it tvheadend-builder-debian /bin/bash
```

### Package Structure Inspection
```bash
# Extract package contents without installing
dpkg-deb -R output/tvheadend-full_*.deb extracted/

# View package info
dpkg-deb -I output/tvheadend-full_*.deb

# List package contents
dpkg-deb -c output/tvheadend-full_*.deb
```

## Architecture Notes

The build system automatically detects and builds for the host architecture:
- **macOS (Apple Silicon)**: Builds arm64 packages
- **macOS (Intel)**: Builds amd64 packages
- **Linux x86_64**: Builds amd64 packages
- **Linux ARM64**: Builds arm64 packages

The architecture is detected using `dpkg --print-architecture` inside the Debian container, ensuring proper Debian package naming conventions (amd64/arm64).
