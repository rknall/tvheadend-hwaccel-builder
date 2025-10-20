# TVHeadend Full - Debian Package Builder

Build a complete TVHeadend Debian package with commercial detection, picons, and EPG tools.

## What's Included

This package includes everything from the dfigus/addon-tvheadend repository:

- **TVHeadend** - TV streaming server and recorder
- **Comskip** - Commercial detection tool
- **Comchap & Comcut** - Chapter markers and commercial removal
- **Picons** - Channel icons (SNP and SRP formats)
- **WebGrab++** - EPG grabber for electronic program guides
- **Streamlink** support (optional dependency)

### Hardware Acceleration Support

Built with support for multiple hardware acceleration methods:

- **VAAPI** - Intel/AMD GPU acceleration (recommended)
- **NVENC** - NVIDIA GPU encoding
- **QSV** - Intel Quick Sync Video
- **VDPAU** - NVIDIA video decoding

The `tvheadend` user is automatically added to `audio`, `video`, and `render` groups for full hardware access.

## Prerequisites

- Docker installed and running
- 4-6GB free disk space
- Internet connection
- Debian/Ubuntu target system (for installation)

## Quick Start

### 1. Build the Package

```bash
chmod +x build-tvheadend.sh
./build-tvheadend.sh
```

**Build time:** 25-35 minutes

### 2. Install on Target System

```bash
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f
```

### 3. Start TVHeadend

```bash
sudo systemctl start tvheadend
sudo systemctl enable tvheadend
```

### 4. Access Web Interface

Open browser: `http://localhost:9981`

**Default Login:**
- Username: `admin`
- Password: `admin`

**IMPORTANT:** Change these credentials immediately after first login!
- Go to: Configuration → Users → Access Entries
- Edit the admin entry and set a strong password

## Hardware Acceleration

### Install Drivers (Recommended)

For best transcoding performance, install hardware acceleration drivers:

```bash
# For Intel/AMD (VAAPI)
sudo apt-get install mesa-va-drivers intel-media-va-driver

# For NVIDIA (VDPAU/NVENC)
sudo apt-get install mesa-vdpau-drivers nvidia-driver

# Verify VAAPI
vainfo

# Check GPU devices
ls -la /dev/dri/
# Should show: card0 (video group), renderD128 (render group)
```

### Groups Explained

The `hts` user is automatically added to these groups:

- **video** - Access to `/dev/dri/card*` (legacy GPU access)
- **render** - Access to `/dev/dri/renderD*` (modern GPU rendering)
- **audio** - Access to audio devices

**Both video AND render groups are needed for modern hardware acceleration!**

### Verify Access

```bash
# Check user groups
id hts
# Should show: groups=... audio(29) video(44) render(109)

# Test as hts user
sudo -u hts vainfo
# Should list supported formats without errors
```

### Enable in TVHeadend

1. Go to: Configuration → Recording → DVR Profiles
2. Create transcoding profile
3. Use hardware encoder (h264_vaapi, h264_nvenc, h264_qsv)

**Note:** User `hts` is automatically in all required groups for hardware access.

## Manual Build (Alternative)

If you prefer manual steps:

```bash
# Build image
docker build -t tvheadend-builder-debian -f Dockerfile.debian .

# Run build
mkdir -p output
docker run --rm -v "$(pwd)/output:/output" tvheadend-builder-debian

# Install
cd output
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f
```

## Features Configuration

### Comskip - Commercial Detection

1. Create configuration file:
```bash
sudo mkdir -p /etc/tvheadend/comskip
sudo nano /etc/tvheadend/comskip/comskip.ini
```

2. Get country-specific configs from: http://www.kaashoek.com/comskip/

3. In TVHeadend:
   - Go to: Configuration → Recording → DVR Profiles
   - Post-processor command:
     ```
     /usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini "%f"
     ```

### Comcut - Remove Commercials

Chain with Comskip to automatically cut commercials:

```bash
/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini "%f" && /usr/bin/comcut "%f"
```

### Picons - Channel Icons

1. Go to: Configuration → General → Base
2. Set "Channel icon path": `file:///opt/picons/snp`
3. Set view level to "Advanced" or "Expert"

### WebGrab++ - EPG Grabber

1. Install runtime (choose one):
```bash
sudo apt-get install dotnet-runtime-8.0
# or
sudo apt-get install mono-runtime
```

2. Configure:
```bash
sudo nano /opt/webgrab/.wg++/WebGrab++.config.xml
```

3. Run manually:
```bash
cd /opt/webgrab/.wg++
mono WebGrab+Plus.exe
```

4. Use in TVHeadend:
   - Configuration → Channel/EPG → EPG Grabber Modules
   - Enable "tv_grab_wg++"

## Package Contents

**Binaries:**
- `/usr/bin/tvheadend` - Main server
- `/usr/bin/comskip` - Commercial detector
- `/usr/bin/comchap` - Add chapter markers
- `/usr/bin/comcut` - Cut commercials
- `/usr/bin/tv_grab_wg++` - EPG grabber wrapper

**Configuration:**
- `/etc/tvheadend/` - TVHeadend config
- `/etc/comskip/` - Comskip config

**Data:**
- `/var/lib/tvheadend/` - Data and recordings
- `/opt/picons/` - Channel icons
- `/opt/webgrab/` - WebGrab++ installation

**Service:**
- `/lib/systemd/system/tvheadend.service`

## Service Management

```bash
# Start/Stop
sudo systemctl start tvheadend
sudo systemctl stop tvheadend
sudo systemctl restart tvheadend

# Status
sudo systemctl status tvheadend

# Logs
sudo journalctl -u tvheadend -f

# Enable/Disable autostart
sudo systemctl enable tvheadend
sudo systemctl disable tvheadend
```

## Complete Setup Example

### 1. Install package
```bash
sudo dpkg -i tvheadend-full_*.deb
sudo apt-get install -f
```

### 2. Configure Comskip
```bash
sudo mkdir -p /etc/tvheadend/comskip
sudo nano /etc/tvheadend/comskip/comskip.ini
```

Add basic config:
```ini
detect_method=43
verbose=10
output_edl=1
output_comskip=1
```

### 3. Start service
```bash
sudo systemctl start tvheadend
sudo systemctl enable tvheadend
```

### 4. Configure via web interface
- Access: http://localhost:9981
- Create admin user
- Run setup wizard
- Configure tuners/IPTV
- Set DVR profile post-processor
- Enable picons path

## Troubleshooting

### Build fails
```bash
# Check Docker
docker info

# Check disk space
df -h

# Clean and retry
docker system prune -a
./build-tvheadend.sh
```

### TVHeadend won't start
```bash
# Check logs
sudo journalctl -u tvheadend -n 50

# Fix permissions
sudo chown -R hts:hts /etc/tvheadend /var/lib/tvheadend
```

### Comskip not working
- Verify comskip.ini exists
- Check post-processor command syntax
- Test manually: `/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini /path/to/recording.ts`

### Picons not showing
- Set view level to "Advanced"
- Check path: `file:///opt/picons/snp`
- Verify files exist: `ls /opt/picons/snp`

### WebGrab++ errors
```bash
# Check runtime
dpkg -l | grep dotnet

# Test manually
cd /opt/webgrab/.wg++
mono WebGrab+Plus.exe
```

## Uninstall

```bash
# Remove package (keep config)
sudo apt-get remove tvheadend-full

# Complete removal
sudo apt-get purge tvheadend-full
sudo rm -rf /var/lib/tvheadend  # Remove recordings too
```

## Build Details

**Build time:** 25-35 minutes
- Docker image: 20-25 minutes
- Package creation: 5-10 minutes

**Disk space:**
- Build: ~4-6GB
- Package: ~10-15MB
- Installed: ~40-60MB (without picons)
- With picons: ~400-500MB

## Dependencies

**Required:**
- Standard Debian libraries (auto-installed)
- xmltv, perl

**Recommended:**
- ffmpeg (transcoding)
- streamlink (stream extraction)
- dotnet-runtime-8.0 or mono-runtime (WebGrab++)

**Optional:**
- pngquant (icon optimization)

## Components

All components match the addon-tvheadend repository:

| Component | Version/Commit |
|-----------|---------------|
| TVHeadend | 7de8bf4826b1847118f3a42556cf0afeee2a5912 |
| Comskip | a140b6ac8bc8f596729e9052819affc779c3b377 |
| Comchap | dd7db30c258e965f282ac78825971dd0703a031e |
| Picons | 2025-10-17--08-28-59 |
| WebGrab++ | v5.3.0 |

## Resources

- **TVHeadend:** https://tvheadend.org
- **Comskip:** http://www.kaashoek.com/comskip/
- **Picons:** https://github.com/picons/picons
- **WebGrab++:** http://www.webgrabplus.com/
- **Original addon:** https://github.com/dfigus/addon-tvheadend

## Support

- TVHeadend Forum: https://tvheadend.org/projects/tvheadend/boards
- Comskip Forum: https://www.kaashoek.com/forum/

## License

- TVHeadend: GPL-3.0
- Comskip: GPL-2.0
- Other components: See respective licenses
