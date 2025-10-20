# Quick Reference - TVHeadend Full

## Quick Build & Install

```bash
# Build
chmod +x build-tvheadend.sh
./build-tvheadend.sh

# Install
cd output
sudo dpkg -i tvheadend-full_*_amd64.deb
sudo apt-get install -f

# Start
sudo systemctl start tvheadend
sudo systemctl enable tvheadend
```

**Web UI:** http://localhost:9981

---

## Manual Docker Commands

```bash
# Build image
docker build -t tvheadend-builder-debian -f Dockerfile.debian .

# Create package
mkdir -p output
docker run --rm -v "$(pwd)/output:/output" tvheadend-builder-debian

# Install
cd output
sudo dpkg -i tvheadend-full_*_amd64.deb
sudo apt-get install -f
```

---

## Service Commands

```bash
# Start/Stop/Restart
sudo systemctl start tvheadend
sudo systemctl stop tvheadend
sudo systemctl restart tvheadend

# Status and logs
sudo systemctl status tvheadend
sudo journalctl -u tvheadend -f
sudo journalctl -u tvheadend -n 100

# Enable/Disable autostart
sudo systemctl enable tvheadend
sudo systemctl disable tvheadend
```

---

## File Locations

| Item | Path |
|------|------|
| TVHeadend binary | `/usr/bin/tvheadend` |
| Comskip | `/usr/bin/comskip` |
| Comchap/Comcut | `/usr/bin/comchap`, `/usr/bin/comcut` |
| Config | `/etc/tvheadend/` |
| Comskip config | `/etc/tvheadend/comskip/` |
| Data/recordings | `/var/lib/tvheadend/` |
| Picons | `/opt/picons/snp`, `/opt/picons/srp` |
| WebGrab++ | `/opt/webgrab/.wg++/` |
| Service file | `/lib/systemd/system/tvheadend.service` |

---

## Comskip Setup

### 1. Create config
```bash
sudo mkdir -p /etc/tvheadend/comskip
sudo nano /etc/tvheadend/comskip/comskip.ini
```

### 2. Basic comskip.ini
```ini
detect_method=43
verbose=10
output_edl=1
output_comskip=1
```

### 3. TVHeadend post-processor
In Configuration → Recording → DVR Profiles:
```bash
# Detect only
/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini "%f"

# Detect and cut
/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini "%f" && /usr/bin/comcut "%f"

# Detect and add chapters
/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini "%f" && /usr/bin/comchap "%f"
```

---

## Picons Setup

In TVHeadend: Configuration → General → Base

- Channel icon path: `file:///opt/picons/snp`
- Or: `file:///opt/picons/srp`
- View level: "Advanced" or "Expert"

---

## WebGrab++ Setup

### Install runtime
```bash
# Option 1: .NET (recommended)
sudo apt-get install dotnet-runtime-8.0

# Option 2: Mono
sudo apt-get install mono-runtime
```

### Configure
```bash
sudo nano /opt/webgrab/.wg++/WebGrab++.config.xml
```

### Run manually
```bash
cd /opt/webgrab/.wg++
mono WebGrab+Plus.exe
```

### Use in TVHeadend
Configuration → Channel/EPG → EPG Grabber Modules
- Enable "tv_grab_wg++"

---

## Troubleshooting

### Service won't start
```bash
sudo journalctl -u tvheadend -n 50
sudo chown -R tvheadend:tvheadend /etc/tvheadend /var/lib/tvheadend
sudo systemctl restart tvheadend
```

### Can't access web interface
```bash
# Check service
sudo systemctl status tvheadend

# Check port
sudo netstat -tlnp | grep 9981

# Check firewall
sudo ufw allow 9981/tcp
```

### Comskip not working
```bash
# Test manually
/usr/bin/comskip --ini=/etc/tvheadend/comskip/comskip.ini /path/to/test.ts

# Check permissions
ls -la /usr/bin/comskip
```

### Picons not visible
```bash
# Verify files
ls /opt/picons/snp

# Check symlink
ls -la /var/lib/tvheadend/picons

# Recreate symlink
sudo ln -sf /opt/picons /var/lib/tvheadend/picons
```

---

## Package Info

```bash
# Check version
dpkg -l | grep tvheadend-full

# List files
dpkg -L tvheadend-full

# Package info
dpkg -s tvheadend-full
```

---

## Uninstall

```bash
# Remove (keep config)
sudo apt-get remove tvheadend-full

# Purge (remove config)
sudo apt-get purge tvheadend-full

# Remove recordings too
sudo rm -rf /var/lib/tvheadend
```

---

## Build Times & Sizes

| Item | Size/Time |
|------|-----------|
| Build time | 25-35 minutes |
| Package size | 10-15 MB |
| Installed (no picons) | ~40-60 MB |
| Installed (with picons) | ~400-500 MB |
| Build disk space | ~4-6 GB |

---

## URLs & Resources

- **Web UI:** http://localhost:9981
- **TVHeadend:** https://tvheadend.org
- **Comskip configs:** http://www.kaashoek.com/comskip/
- **Picons:** https://github.com/picons/picons
- **WebGrab++:** http://www.webgrabplus.com/

---

## Quick Comskip.ini Examples

### US Cable
```ini
detect_method=43
min_commercialbreak=45
max_commercialbreak=900
min_commercial=15
max_commercial=600
```

### European DVB
```ini
detect_method=107
min_commercialbreak=60
max_commercialbreak=600
min_commercial=20
max_commercial=420
```

### Adjust sensitivity
```ini
max_avg_brightness=60
min_black_frames_for_break=4
```

Download more: http://www.kaashoek.com/comskip/

---

## First-Time Setup Checklist

- [ ] Install package
- [ ] Start service
- [ ] Access web UI (http://localhost:9981)
- [ ] Create admin user
- [ ] Run setup wizard
- [ ] Configure tuners/IPTV
- [ ] Set up picons path
- [ ] Create comskip.ini
- [ ] Configure DVR profile post-processor
- [ ] Test recording

---

## Getting Help

- TVHeadend: https://tvheadend.org/projects/tvheadend/boards
- Comskip: https://www.kaashoek.com/forum/
- Check logs: `sudo journalctl -u tvheadend -f`
