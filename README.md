# TVHeadend Hardware Accelerated Builder

![Build Status](https://github.com/rknall/tvheadend-hwaccel-builder/actions/workflows/build.yml/badge.svg)
![Docker Build](https://github.com/rknall/tvheadend-hwaccel-builder/actions/workflows/docker.yml/badge.svg)
![License](https://img.shields.io/github/license/rknall/tvheadend-hwaccel-builder)

**Core Components:**
![TVHeadend](https://img.shields.io/badge/TVHeadend-4.3--dev-orange)
![FFmpeg](https://img.shields.io/badge/FFmpeg-7.1.2-green)
![libvpl](https://img.shields.io/badge/libvpl-2.15.0-green)

**Addons:**
![Comskip](https://img.shields.io/badge/Comskip-latest-blue)
![Picons](https://img.shields.io/badge/Picons-2025--10--17-blue)
![WebGrab++](https://img.shields.io/badge/WebGrab++-5.3.0-blue)

**Platforms:**
![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-blue)

A modular builder for TVHeadend with full hardware acceleration support (VAAPI, NVENC, QSV, VDPAU), commercial detection, channel icons, and EPG tools.

Available as **Debian packages** or **Docker container**.

## Overview

This project builds TVHeadend from source with hardware acceleration and provides two deployment options:

### Option 1: Debian Packages

Creates **5 modular Debian packages** that can be installed independently or together:

1. **tvheadend** - Core TV streaming server with hardware acceleration
2. **tvheadend-comskip** - Commercial detection and removal (Comskip, Comchap, Comcut)
3. **tvheadend-picons** - Channel icons for EPG (220x132 px, SNP and SRP formats)
4. **tvheadend-webgrab** - EPG grabber (WebGrab++ with tv_grab_wg++ wrapper)
5. **tvheadend-full** - Meta-package that installs all of the above

### Option 2: Docker Container

Pre-built Docker image with everything included:
- Multi-architecture support (amd64, arm64)
- All components pre-installed
- Easy deployment with docker-compose
- Available on Docker Hub: `rknall/tvheadend-hwaccel`

See [Docker Documentation](docs/DOCKER.md) for details.

### Key Features

- **Hardware Acceleration**: Built-in support for VAAPI, NVENC, QSV, and VDPAU
- **Modular Packages**: Install only what you need (core only ~40MB vs full ~500MB)
- **Commercial Detection**: Integrated Comskip with automated commercial removal
- **Channel Icons**: Pre-configured picons for professional EPG appearance
- **Docker-based Build**: Reproducible builds, no system pollution
- **Multi-architecture**: Supports amd64 and arm64

### Future Plans

This builder is designed to be extensible. Planned additions:
- RPM packages (Fedora/RHEL/CentOS)
- Alpine APK packages
- Automated CI/CD builds

## Quick Start

Choose your preferred deployment method:

### Option A: Docker Container (Recommended for Quick Setup)

```bash
# Using docker run
docker run -d \
  --name tvheadend \
  -p 9981:9981 -p 9982:9982 \
  -v /path/to/config:/var/lib/tvheadend \
  -v /path/to/recordings:/recordings \
  --device /dev/dri:/dev/dri \
  rknall/tvheadend-hwaccel:latest

# Or using docker-compose
curl -O https://raw.githubusercontent.com/rknall/tvheadend-hwaccel-builder/main/docker-compose.yml
docker compose up -d
```

Access web interface at `http://localhost:9981` (default: admin/admin)

Full Docker documentation: [docs/DOCKER.md](docs/DOCKER.md)

### Option B: Build Debian Packages

#### Prerequisites

- Docker installed and running
- 4-6GB free disk space
- Internet connection
- Target system: Debian 12 (Bookworm) or Ubuntu 22.04+

#### Build Commands

```bash
git clone https://github.com/rknall/tvheadend-hwaccel-builder.git
cd tvheadend-hwaccel-builder
chmod +x build-tvheadend.sh

# Build Debian packages
./build-tvheadend.sh

# Or build Docker container
./build-tvheadend.sh --docker
```

**Build time:** 25-35 minutes (first build, faster with Docker cache)

Packages will be created in `./output/`:
- `tvheadend_<version>_<arch>.deb` (~10MB)
- `tvheadend-comskip_<version>_<arch>.deb` (~2MB)
- `tvheadend-picons_<version>_all.deb` (~450MB)
- `tvheadend-webgrab_<version>_all.deb` (~5MB)
- `tvheadend-full_<version>_all.deb` (~1KB meta-package)

### Install on Target System

**Option 1: Install everything**
```bash
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f
```

**Option 2: Install core only** (minimal install)
```bash
cd output
sudo dpkg -i tvheadend_*.deb
sudo apt-get install -f
```

**Option 3: Custom selection**
```bash
cd output
sudo dpkg -i tvheadend_*.deb tvheadend-comskip_*.deb
sudo apt-get install -f
```

### First Time Setup

After installation, you'll be prompted to create admin credentials:

```bash
sudo dpkg-reconfigure tvheadend
```

Then start the service:

```bash
sudo systemctl start tvheadend
sudo systemctl enable tvheadend
```

Access the web interface at: **http://localhost:9981**

## Hardware Acceleration

### Why Hardware Acceleration Matters

Hardware-accelerated transcoding can reduce CPU usage by 80-90% and enable:
- Multiple simultaneous transcoding streams
- Lower power consumption
- Higher quality transcoding at lower bitrates
- 4K transcoding on modest hardware

### Supported Hardware

- **Intel GPUs** (amd64 only): 6th gen and newer (VAAPI, QSV)
- **AMD GPUs**: All GCN and newer (VAAPI)
- **NVIDIA GPUs**: GTX 600 series and newer (NVENC, VDPAU)

**Note:** Intel Quick Sync (QSV) via libvpl is only available in amd64 builds. ARM64 builds support VAAPI, NVENC, and VDPAU but not QSV.

### Install Hardware Drivers

```bash
# For Intel/AMD (VAAPI)
sudo apt-get install mesa-va-drivers intel-media-va-driver

# For NVIDIA (NVENC/VDPAU)
sudo apt-get install nvidia-driver nvidia-vaapi-driver

# Verify hardware acceleration is available
vainfo
```

### User Permissions

The tvheadend package automatically configures the `hts` user with proper hardware access:
- Added to `video` group (legacy GPU access)
- Added to `render` group (modern GPU rendering)
- Added to `audio` group (audio devices)

Verify with:
```bash
id hts
# Should show: groups=... audio(29) video(44) render(109)
```

### Enable in TVHeadend

1. Navigate to: **Configuration → Recording → DVR Profiles**
2. Create or edit a profile
3. Set video codec to:
   - `h264_vaapi` (Intel/AMD)
   - `h264_nvenc` (NVIDIA)
   - `h264_qsv` (Intel Quick Sync)

## Modular Package Benefits

The 5-package structure provides flexibility:

| Package | Size | Purpose | Install When |
|---------|------|---------|--------------|
| tvheadend | ~10MB | Core server | Always (required) |
| tvheadend-comskip | ~2MB | Ad detection | You want commercial skipping |
| tvheadend-picons | ~450MB | Channel icons | You want professional EPG appearance |
| tvheadend-webgrab | ~5MB | EPG grabber | You need EPG data from web sources |
| tvheadend-full | ~1KB | Meta-package | You want everything |

**Example Use Cases:**

- **Minimal server**: Install only `tvheadend` (~10MB)
- **With commercials removed**: `tvheadend` + `tvheadend-comskip` (~12MB)
- **Complete setup**: `tvheadend-full` (installs all packages, ~500MB)

## Package Contents

### tvheadend (core)
```
/usr/bin/tvheadend              Main server binary
/etc/tvheadend/                 Configuration directory
/var/lib/tvheadend/             Data and recordings
/lib/systemd/system/            Systemd service
```

### tvheadend-comskip
```
/usr/bin/comskip                Commercial detection
/usr/bin/comchap                Chapter marker tool
/usr/bin/comcut                 Commercial removal tool
/etc/comskip/                   Configuration directory
```

### tvheadend-picons
```
/opt/picons/snp/                Service Name Picons (220x132)
/opt/picons/srp/                Service Reference Picons (220x132)
/var/lib/tvheadend/picons       Symlink to /opt/picons
```

### tvheadend-webgrab
```
/usr/bin/tv_grab_wg++           TVHeadend wrapper script
/opt/webgrab/.wg++/             WebGrab++ installation
/var/lib/tvheadend/webgrab/     EPG output directory
```

## Configuration Examples

### Commercial Detection (Comskip)

Create a post-processor script in your DVR profile:

```bash
# Configuration → Recording → DVR Profiles → Post-processor command:
/usr/bin/comskip --ini=/etc/comskip/comskip.ini "%f"
```

Or automatically remove commercials:
```bash
/usr/bin/comskip --ini=/etc/comskip/comskip.ini "%f" && /usr/bin/comcut "%f"
```

Sample comskip.ini:
```ini
detect_method=43
verbose=10
output_edl=1
output_comskip=1
output_videoredo=1
```

### Channel Icons (Picons)

1. Navigate to: **Configuration → General → Base**
2. Set "Channel icon path": `file:///opt/picons/snp`
3. Icons will appear automatically for matching channels

### EPG Grabber (WebGrab++)

1. Install runtime:
```bash
sudo apt-get install dotnet-runtime-8.0
# or
sudo apt-get install mono-runtime
```

2. Configure channels:
```bash
sudo nano /opt/webgrab/.wg++/WebGrab++.config.xml
```

3. Enable in TVHeadend:
   - **Configuration → Channel/EPG → EPG Grabber Modules**
   - Enable "tv_grab_wg++"

## Service Management

```bash
# Start/Stop
sudo systemctl start tvheadend
sudo systemctl stop tvheadend
sudo systemctl restart tvheadend

# Status and logs
sudo systemctl status tvheadend
sudo journalctl -u tvheadend -f

# Enable/disable autostart
sudo systemctl enable tvheadend
sudo systemctl disable tvheadend
```

## Build Options

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
```

## Troubleshooting

### 403 Error After Installation

If you get a 403 error when accessing the web interface:

```bash
# Fix directory permissions
sudo chown -R hts:hts /var/lib/tvheadend
sudo systemctl restart tvheadend
```

This is fixed in the latest version of the package.

### TVHeadend Won't Start

```bash
# Check logs for errors
sudo journalctl -u tvheadend -n 50

# Verify user and permissions
id hts
ls -la /var/lib/tvheadend

# Fix permissions if needed
sudo chown -R hts:hts /var/lib/tvheadend
```

### Hardware Acceleration Not Working

```bash
# Verify drivers are installed
vainfo

# Check device permissions
ls -la /dev/dri/
# Should show card0 (video group) and renderD128 (render group)

# Test as hts user
sudo -u hts vainfo
# Should list supported formats without permission errors

# Verify hts user groups
id hts
# Must include: video, render
```

### Comskip Not Detecting Commercials

```bash
# Test manually
/usr/bin/comskip --ini=/etc/comskip/comskip.ini /path/to/recording.ts

# Check logs
ls -la /path/to/recording.*
# Should see .edl, .txt, .log files after comskip runs

# Tune detection settings in /etc/comskip/comskip.ini
# Country-specific configs: http://www.kaashoek.com/comskip/
```

### Build Failures

```bash
# Check Docker status
docker info

# Check disk space (need 4-6GB)
df -h

# Clean Docker cache and rebuild
docker system prune -a
./build-tvheadend.sh --clean
```

## Component Versions

Current versions match the [dfigus/addon-tvheadend](https://github.com/dfigus/addon-tvheadend) repository:

| Component | Version/Commit |
|-----------|---------------|
| TVHeadend | 7de8bf4826b1847118f3a42556cf0afeee2a5912 |
| Comskip | a140b6ac8bc8f596729e9052819affc779c3b377 |
| Comchap/Comcut | dd7db30c258e965f282ac78825971dd0703a031e |
| Picons | 2025-10-17--08-28-59 |
| WebGrab++ | v5.3.0 |

To update versions, modify the ARG variables in `Dockerfile.debian`.

## Architecture Support

- **Core packages** (tvheadend, comskip): Built for host architecture (amd64 or arm64)
- **Architecture-independent** (picons, webgrab, full): Built as `all`

The build automatically detects your system architecture.

## Uninstall

```bash
# Remove package (keep configuration)
sudo apt-get remove tvheadend-full

# Complete removal (including config and data)
sudo apt-get purge tvheadend-full
sudo rm -rf /var/lib/tvheadend  # Remove recordings too
```

## Project Structure

```
tvheadend-hwaccel-builder/
├── Dockerfile.debian           Docker build for Debian packages
├── build-tvheadend.sh          Build script wrapper
├── debian/
│   ├── control-*.template      Package metadata
│   ├── postinst*               Post-installation scripts
│   ├── prerm*                  Pre-removal scripts
│   └── postrm*                 Post-removal scripts
├── CLAUDE.md                   Development guidance
├── CHANGELOG.md                Change history
├── FIX_SUMMARY.md             Bug fixes documentation
└── output/                     Built packages (created during build)
```

## Contributing

Contributions welcome! Areas for improvement:

- RPM package builds (Fedora/RHEL)
- Alpine APK package builds
- CI/CD automation (GitLab/GitHub Actions)
- Additional hardware acceleration testing
- Documentation improvements

## Resources

- **TVHeadend**: https://tvheadend.org
- **TVHeadend Documentation**: https://tvheadend.org/projects/tvheadend/wiki
- **Comskip**: http://www.kaashoek.com/comskip/
- **Picons**: https://github.com/picons/picons
- **WebGrab++**: http://www.webgrabplus.com/
- **Original Addon**: https://github.com/dfigus/addon-tvheadend

## License

- TVHeadend: GPL-3.0
- Comskip: GPL-2.0
- This builder: MIT
- Other components: See respective licenses

## Support

For TVHeadend support:
- Forum: https://tvheadend.org/projects/tvheadend/boards
- IRC: #tvheadend on Libera.Chat

For build issues:
- Open an issue on GitHub

## Acknowledgments

Based on the excellent work in [dfigus/addon-tvheadend](https://github.com/dfigus/addon-tvheadend).
