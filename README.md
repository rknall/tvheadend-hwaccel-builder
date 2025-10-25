# TVHeadend Hardware Acceleration Packages

This repository provides Debian packages for TVHeadend with hardware acceleration support (VAAPI, NVENC, QSV).

**Last Updated:** Sat, 25 Oct 2025 11:37:36 +0000
**Architecture:** amd64, all (architecture-independent packages)

## Quick Start

Add the repository to your Debian/Ubuntu system:

```bash
# Add the repository
echo "deb [trusted=yes] https://rknall.github.io/tvheadend-hwaccel-builder/debian/ stable main" | sudo tee /etc/apt/sources.list.d/tvheadend-hwaccel.list

# Update package list
sudo apt-get update

# Install full suite
sudo apt-get install tvheadend-full
```

## Available Packages

### TVHeadend Packages

#### tvheadend-comskip
- **Version:** 4.3-v4.3-2500-g7de8bf482-dirty
- **Architecture:** amd64
- **Size:** 471K
- **Description:** Commercial detection and removal tools for TVHeadend

#### tvheadend-full
- **Version:** 4.3-v4.3-2500-g7de8bf482-dirty
- **Architecture:** all
- **Size:** 1020
- **Description:** Complete TVHeadend installation with all extras (meta-package)

#### tvheadend-picons
- **Version:** 4.3-v4.3-2500-g7de8bf482-dirty
- **Architecture:** all
- **Size:** 65M
- **Description:** Channel icons (picons) for TVHeadend

#### tvheadend-webgrab
- **Version:** 4.3-v4.3-2500-g7de8bf482-dirty
- **Architecture:** all
- **Size:** 5.7M
- **Description:** WebGrab++ EPG grabber for TVHeadend

#### tvheadend
- **Version:** 4.3-v4.3-2500-g7de8bf482-dirty
- **Architecture:** amd64
- **Size:** 14M
- **Description:** TV streaming server with hardware acceleration

### Dependency Packages (FFmpeg & libvpl)

These packages are automatically installed as dependencies:

- **ffmpeg-dbgsym** (7:7.1.2-1) - amd64, 763K
- **ffmpeg-doc** (7:7.1.2-1) - all, 2.3M
- **ffmpeg** (7:7.1.2-1) - amd64, 2.0M
- **libavcodec-dev** (7:7.1.2-1) - amd64, 5.9M
- **libavcodec-extra61-dbgsym** (7:7.1.2-1) - amd64, 22M
- **libavcodec-extra61** (7:7.1.2-1) - amd64, 5.4M
- **libavcodec-extra** (7:7.1.2-1) - amd64, 55K
- **libavcodec61-dbgsym** (7:7.1.2-1) - amd64, 22M
- **libavcodec61** (7:7.1.2-1) - amd64, 5.4M
- **libavdevice-dev** (7:7.1.2-1) - amd64, 125K
- **libavdevice61-dbgsym** (7:7.1.2-1) - amd64, 218K
- **libavdevice61** (7:7.1.2-1) - amd64, 115K
- **libavfilter-dev** (7:7.1.2-1) - amd64, 1.8M
- **libavfilter-extra10-dbgsym** (7:7.1.2-1) - amd64, 5.8M
- **libavfilter-extra10** (7:7.1.2-1) - amd64, 1.6M
- **libavfilter-extra** (7:7.1.2-1) - amd64, 55K
- **libavfilter10-dbgsym** (7:7.1.2-1) - amd64, 5.8M
- **libavfilter10** (7:7.1.2-1) - amd64, 1.6M
- **libavformat-dev** (7:7.1.2-1) - amd64, 1.4M
- **libavformat-extra61-dbgsym** (7:7.1.2-1) - amd64, 3.5M
- **libavformat-extra61** (7:7.1.2-1) - amd64, 1.2M
- **libavformat-extra** (7:7.1.2-1) - amd64, 55K
- **libavformat61-dbgsym** (7:7.1.2-1) - amd64, 3.5M
- **libavformat61** (7:7.1.2-1) - amd64, 1.2M
- **libavutil-dev** (7:7.1.2-1) - amd64, 510K
- **libavutil59-dbgsym** (7:7.1.2-1) - amd64, 852K
- **libavutil59** (7:7.1.2-1) - amd64, 363K
- **libpostproc-dev** (7:7.1.2-1) - amd64, 85K
- **libpostproc58-dbgsym** (7:7.1.2-1) - amd64, 64K
- **libpostproc58** (7:7.1.2-1) - amd64, 84K
- **libswresample-dev** (7:7.1.2-1) - amd64, 112K
- **libswresample5-dbgsym** (7:7.1.2-1) - amd64, 109K
- **libswresample5** (7:7.1.2-1) - amd64, 98K
- **libswscale-dev** (7:7.1.2-1) - amd64, 254K
- **libswscale8-dbgsym** (7:7.1.2-1) - amd64, 683K
- **libswscale8** (7:7.1.2-1) - amd64, 225K
- **libvpl-dev** (1:2.15.0-1) - amd64, 101K
- **libvpl-examples-dbgsym** (1:2.15.0-1) - amd64, 190K
- **libvpl-examples** (1:2.15.0-1) - amd64, 4.3M
- **libvpl2-dbgsym** (1:2.15.0-1) - amd64, 1.6M
- **libvpl2** (1:2.15.0-1) - amd64, 118K

## Installation Options

### Full Installation (Recommended)
Installs TVHeadend with all optional components:

\`\`\`bash
sudo apt-get install tvheadend-full
\`\`\`

This includes:
- TVHeadend core server
- Comskip (commercial detection)
- Picons (channel icons)
- WebGrab++ (EPG grabber)

### Core Only
Minimal installation with just the TVHeadend server:

\`\`\`bash
sudo apt-get install tvheadend
\`\`\`

### Custom Selection
Pick and choose components:

\`\`\`bash
# Core + commercial detection
sudo apt-get install tvheadend tvheadend-comskip

# Core + channel icons
sudo apt-get install tvheadend tvheadend-picons

# Core + EPG grabber
sudo apt-get install tvheadend tvheadend-webgrab
\`\`\`

## Hardware Acceleration Support

The packages include support for:

- **VAAPI** - Intel/AMD GPU acceleration
- **NVENC/NVDEC** - NVIDIA GPU encoding/decoding
- **QSV** - Intel Quick Sync Video
- **VDPAU** - NVIDIA video decoding (legacy)

## Package Details

### tvheadend
Core TV streaming server with:
- Multi-format recording (TS, Matroska, MP4)
- Hardware-accelerated transcoding
- Web interface on port 9981
- HTSP streaming on port 9982
- EPG support
- DVB, IPTV, SAT>IP, and HDHomeRun support

### tvheadend-comskip
Commercial detection suite:
- **comskip** - Detects commercials in recordings
- **comchap** - Adds chapter markers at commercial breaks
- **comcut** - Removes commercials from recordings

### tvheadend-picons
Channel icon library (~65MB):
- SNP format (Service Name Picons)
- SRP format (Service Reference Picons)
- Automatically linked to TVHeadend

### tvheadend-webgrab
EPG data grabber:
- WebGrab++ v5.3.0
- tv_grab_wg++ wrapper for TVHeadend integration
- Supports multiple EPG sources

## System Requirements

- Debian 12 (Bookworm) or Ubuntu 24.04+
- For hardware acceleration:
  - Intel: i965-va-driver or intel-media-va-driver
  - NVIDIA: nvidia-driver with CUDA support
  - AMD: mesa-va-drivers

## Post-Installation

1. Access web interface: http://your-server-ip:9981
2. Default credentials: admin / admin (change immediately!)
3. Configure tuners and networks
4. Set up EPG sources
5. Enable hardware acceleration in transcoding profiles

## Manual Download

Download .deb files directly:
- [GitHub Releases](https://github.com/rknall/tvheadend-hwaccel-builder/releases)
- [Artifacts from latest build](https://github.com/rknall/tvheadend-hwaccel-builder/actions)

## Build Information

- **Repository:** https://github.com/rknall/tvheadend-hwaccel-builder
- **CI/CD:** GitHub Actions
- **Build Time:** ~26 minutes
- **Source:**
  - TVHeadend: [tvheadend/tvheadend](https://github.com/tvheadend/tvheadend)
  - FFmpeg: 7.1.2 (Debian packaging)
  - libvpl: 2.15.0 (Intel Video Processing Library)

## Support

- [Report Issues](https://github.com/rknall/tvheadend-hwaccel-builder/issues)
- [TVHeadend Documentation](https://tvheadend.org/projects/tvheadend/wiki)
- [TVHeadend Forums](https://tvheadend.org/d/)
