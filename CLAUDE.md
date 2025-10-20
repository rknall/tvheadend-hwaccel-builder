# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular Debian package builder for TVHeadend and related components. It creates 5 separate packages that can be installed independently or together:

1. **tvheadend** - Core TV streaming server with hardware acceleration
2. **tvheadend-comskip** - Commercial detection and removal tools (Comskip, Comchap, Comcut)
3. **tvheadend-picons** - Channel icons for EPG (SNP and SRP formats)
4. **tvheadend-webgrab** - EPG grabber (WebGrab++ with tv_grab_wg++ wrapper)
5. **tvheadend-full** - Meta-package that installs all of the above

The build process uses Docker to compile from source and create all packages with hardware acceleration support (VAAPI, NVENC, QSV, VDPAU).

**Architecture Support:**
- Core package (tvheadend) and comskip: Built for host architecture (amd64 or arm64)
- Picons, WebGrab++, and meta-package: Architecture-independent (all)

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

# Install packages (choose one option)
cd output

# Option 1: Install everything
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f

# Option 2: Install core only
sudo dpkg -i tvheadend_*.deb
sudo apt-get install -f

# Option 3: Custom selection
sudo dpkg -i tvheadend_*.deb tvheadend-comskip_*.deb tvheadend-picons_*.deb
sudo apt-get install -f
```

**Build time:** 25-35 minutes (20-25 min for Docker image, 5-10 min for packages)

## Architecture

### Build Process Flow
1. **Dockerfile.debian** - Docker build that:
   - Compiles TVHeadend from source (commit: 7de8bf4826b1847118f3a42556cf0afeee2a5912)
   - Compiles Comskip from source (commit: a140b6ac8bc8f596729e9052819affc779c3b377)
   - Downloads Comchap/Comcut scripts (commit: dd7db30c258e965f282ac78825971dd0703a031e)
   - Downloads Picons channel icons (release: 2025-10-17--08-28-59)
   - Downloads WebGrab++ EPG grabber (v5.3.0)
   - Creates 5 separate package structures:
     - `pkg-tvheadend/` - Core server files
     - `pkg-comskip/` - Commercial detection binaries
     - `pkg-picons/` - Channel icon files
     - `pkg-webgrab/` - EPG grabber files
     - `pkg-full/` - Meta-package (dependencies only)
   - Builds all 5 .deb packages

2. **build-tvheadend.sh** - Wrapper script that:
   - Validates Docker environment
   - Builds the Docker image
   - Runs the container to generate all 5 .deb packages
   - Outputs packages to `./output/` directory

### Package Structure

**tvheadend** (core package):
- `/usr/bin/tvheadend` - Main server binary
- `/etc/tvheadend/` - Configuration directory
- `/etc/default/tvheadend` - Default configuration (user, group, options)
- `/var/lib/tvheadend/` - Data directory and recordings
- `/lib/systemd/system/tvheadend.service` - Systemd service file

**tvheadend-comskip**:
- `/usr/bin/comskip` - Commercial detection binary
- `/usr/bin/comchap` - Add chapter markers script
- `/usr/bin/comcut` - Remove commercials script
- `/etc/comskip/` - Comskip configuration directory

**tvheadend-picons**:
- `/opt/picons/snp/` - Service Name Picons (220x132)
- `/opt/picons/srp/` - Service Reference Picons (220x132)
- Creates symlink: `/var/lib/tvheadend/picons` -> `/opt/picons`

**tvheadend-webgrab**:
- `/usr/bin/tv_grab_wg++` - TVHeadend grabber wrapper
- `/opt/webgrab/.wg++/` - WebGrab++ installation
- `/var/lib/tvheadend/webgrab/` - EPG output directory (guide.xml)

**tvheadend-full**:
- Meta-package with no files, only dependencies on all other packages

**User Configuration:**
- Service runs as user `hts` with group `video` (created by tvheadend core package)
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

Each package has its own control file and maintenance scripts:

### tvheadend (core package)
- **control-tvheadend.template** - Package metadata with core dependencies
- **postinst** - Creates `hts` user, directories, enables systemd service, sets up superuser credentials
- **prerm** - Stops and disables systemd service
- **postrm** - On purge: removes user, group, and config directories
- **config/templates** - Debconf prompts for admin credentials
- **/etc/default/tvheadend** - Sets `OPTIONS="-u hts -g video"`

### tvheadend-comskip
- **control-comskip.template** - Package metadata, recommends tvheadend
- **postinst-comskip** - Creates `/etc/comskip` directory
- **postrm-comskip** - On purge: removes comskip config directory

### tvheadend-picons
- **control-picons.template** - Package metadata, architecture: all
- **postinst-picons** - Creates symlink `/var/lib/tvheadend/picons` -> `/opt/picons`
- **postrm-picons** - Removes picons symlink

### tvheadend-webgrab
- **control-webgrab.template** - Package metadata with WebGrab++ dependencies
- **postinst-webgrab** - Creates `/var/lib/tvheadend/webgrab` directory
- **postrm-webgrab** - On purge: removes webgrab data directory

### tvheadend-full
- **control-full.template** - Meta-package with dependencies on all other packages
- No postinst/postrm scripts (no files to manage)

## Docker Specifics

- Base image: `debian:bookworm`
- Build directory: `/build` (inside container)
- Output directory: `/output` (mounted from host)
- The Dockerfile uses multi-stage build patterns with all compilation in one stage
- ccache is available to speed up rebuilds

## Testing the Packages

After building, test on a Debian/Ubuntu system:

### Test Full Installation
```bash
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f

# Verify all packages installed
dpkg -l | grep tvheadend
# Should show: tvheadend, tvheadend-comskip, tvheadend-picons, tvheadend-webgrab, tvheadend-full

# Start service
sudo systemctl start tvheadend
sudo systemctl status tvheadend

# Check logs
sudo journalctl -u tvheadend -f

# Access web UI
# Open http://localhost:9981
```

### Test Core Only Installation
```bash
cd output
sudo dpkg -i tvheadend_*.deb
sudo apt-get install -f

# Verify only core installed
dpkg -l | grep tvheadend
# Should show only: tvheadend

# Check service
sudo systemctl status tvheadend
```

### Test Individual Package Installation
```bash
# Install in dependency order
cd output
sudo dpkg -i tvheadend_*.deb
sudo dpkg -i tvheadend-comskip_*.deb
sudo dpkg -i tvheadend-picons_*.deb
sudo dpkg -i tvheadend-webgrab_*.deb
sudo apt-get install -f

# Verify components installed correctly
ls -la /usr/bin/comskip /usr/bin/comchap /usr/bin/comcut
ls -la /opt/picons/
ls -la /opt/webgrab/.wg++/
ls -la /var/lib/tvheadend/picons  # Should be symlink to /opt/picons
```

## Common Development Tasks

### Modifying TVHeadend Build Configuration
Edit the `./configure` flags in Dockerfile.debian at line 42. Key flags:
- `--enable-*` / `--disable-*` - Enable/disable features
- `--enable-bundle` - Bundle web interface
- Hardware acceleration flags: `--enable-vaapi`, `--enable-nvenc`, `--enable-qsv`

### Adding New Dependencies
1. Add build dependencies to the `apt-get install` section (lines 17-27) in Dockerfile.debian
2. Add runtime dependencies to the appropriate control file template:
   - Core dependencies: `debian/control-tvheadend.template`
   - Comskip dependencies: `debian/control-comskip.template`
   - WebGrab++ dependencies: `debian/control-webgrab.template`
   - Picons usually has no dependencies (architecture: all)
3. Use `Depends:` for required dependencies, `Recommends:` for optional but suggested, `Suggests:` for nice-to-have

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
# List all built packages
ls -lh output/*.deb

# View package info for any package
dpkg-deb -I output/tvheadend_*.deb
dpkg-deb -I output/tvheadend-comskip_*.deb
dpkg-deb -I output/tvheadend-picons_*.deb
dpkg-deb -I output/tvheadend-webgrab_*.deb
dpkg-deb -I output/tvheadend-full_*.deb

# List contents of a specific package
dpkg-deb -c output/tvheadend_*.deb
dpkg-deb -c output/tvheadend-comskip_*.deb

# Extract package contents without installing
dpkg-deb -R output/tvheadend_*.deb extracted/tvheadend/
dpkg-deb -R output/tvheadend-comskip_*.deb extracted/comskip/

# View dependencies
dpkg-deb -f output/tvheadend-full_*.deb Depends
```

## Multi-Package Architecture Benefits

The modular package structure provides several advantages:

1. **Smaller Install Size**: Users who don't need picons save 50-100 MB
2. **Independent Updates**: Update commercial detection without touching core server
3. **Flexible Deployment**: Install only core on servers, full suite on workstations
4. **Proper Dependencies**: Each package specifies exactly what it needs
5. **Easy Uninstall**: Remove picons without affecting TVHeadend core
6. **Clear Ownership**: Each package manages its own files and directories

**Dependency Chain:**
- `tvheadend-full` depends on all other packages (exact version match)
- `tvheadend-comskip` recommends `tvheadend` (can be installed standalone)
- `tvheadend-picons` suggests `tvheadend` (can be installed standalone)
- `tvheadend-webgrab` suggests `tvheadend` (can be installed standalone)
- `tvheadend` (core) recommends `tvheadend-comskip`, suggests others

## Architecture Notes

The build system automatically detects and builds for the host architecture:
- **macOS (Apple Silicon)**: Builds arm64 packages for core/comskip
- **macOS (Intel)**: Builds amd64 packages for core/comskip
- **Linux x86_64**: Builds amd64 packages for core/comskip
- **Linux ARM64**: Builds arm64 packages for core/comskip

Architecture-independent packages (picons, webgrab, full) are always built as `all`.

The architecture is detected using `dpkg --print-architecture` inside the Debian container, ensuring proper Debian package naming conventions (amd64/arm64).
