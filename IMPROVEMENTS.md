# Improvements Based on Official TVHeadend Dockerfile

## Overview

After analyzing the official TVHeadend Docker image, we've incorporated several critical improvements to ensure better hardware acceleration support and proper system integration.

## Key Improvements

### 1. Hardware Acceleration Support ⭐ CRITICAL

**What Changed:**
```dockerfile
# Added to TVHeadend configure:
--enable-nvenc              # NVIDIA encoding
--enable-qsv                # Intel Quick Sync Video
--enable-bundle             # Bundle web interface
--disable-doc               # Skip documentation build

# Added to package dependencies:
Recommends: mesa-va-drivers, mesa-vdpau-drivers, intel-media-va-driver
Suggests: nvidia-driver
```

**Why This Matters:**
- VAAPI: Intel/AMD GPU transcoding (significant CPU savings)
- NVENC: NVIDIA GPU encoding (10x faster than CPU)
- QSV: Intel Quick Sync (hardware H.264/HEVC encoding)
- VDPAU: NVIDIA video decoding acceleration

**User Impact:**
- Much lower CPU usage during transcoding
- More simultaneous streams possible
- Better quality at lower bitrates
- Cooler, quieter system

### 2. User/Group Configuration ⭐ CRITICAL

**What Changed:**
```bash
# In postinst script:
usermod -a -G audio,video tvheadend

# Creates with proper permissions:
/var/log/tvheadend          # Log directory
/var/lib/tvheadend/recordings  # With 775 permissions
```

**Why This Matters:**
- `audio` group: Access to audio devices
- `video` group: Access to `/dev/dri/*` (GPU devices)
- Without these, hardware acceleration won't work!

**User Impact:**
- Hardware encoding "just works" after installation
- No manual group configuration needed
- DVB tuners and capture cards accessible

### 3. Better Configure Flags

**What Changed:**
```bash
# Official Dockerfile approach:
--disable-doc               # Don't build docs (faster build)
--disable-execinfo          # Not needed on Linux
--disable-*_static          # Use system libraries
--enable-bundle             # Self-contained web interface
```

**Why This Matters:**
- Faster build times
- Smaller package size
- Uses system-maintained libraries (security updates)
- Bundle ensures web interface always works

### 4. Directory Structure

**What Changed:**
```bash
# Now creates:
/var/log/tvheadend          # Logs (not mixed with data)
/var/lib/tvheadend          # Data directory
/var/lib/tvheadend/recordings  # 775 permissions (group writable)
/etc/tvheadend              # Configuration
```

**Why This Matters:**
- Follows Linux Filesystem Hierarchy Standard
- Easier log rotation
- Better backup strategies
- Proper separation of concerns

### 5. Git Safe Directory

**What Changed:**
```bash
git config --global --add safe.directory '/build/tvheadend/data/dvb-scan'
```

**Why This Matters:**
- Prevents git errors during build
- Matches official Dockerfile approach
- Cleaner build output

## Hardware Acceleration Setup

### For Users

After installing the package:

```bash
# Install drivers
sudo apt-get install mesa-va-drivers intel-media-va-driver

# For NVIDIA
sudo apt-get install mesa-vdpau-drivers nvidia-driver

# Verify
vainfo
ls -la /dev/dri/

# User is already in correct groups!
groups tvheadend
# Output: tvheadend audio video
```

### In TVHeadend

1. Configuration → Recording → DVR Profiles
2. Create profile with hardware encoder:
   - Intel: `h264_vaapi` or `hevc_vaapi`
   - NVIDIA: `h264_nvenc` or `hevc_nvenc`
   - Intel QSV: `h264_qsv`

## Comparison: Before vs After

### Before (Our Old Dockerfile)
```
❌ No NVENC support
❌ No QSV support
❌ User not in video/audio groups
❌ No log directory
⚠️  VAAPI enabled but likely non-functional
```

### After (With Official Improvements)
```
✅ NVENC enabled
✅ QSV enabled
✅ User in video/audio groups
✅ Proper log directory
✅ VAAPI fully functional
✅ Follows FHS standards
✅ Hardware acceleration "just works"
```

## Testing Hardware Acceleration

### Verify Installation

```bash
# Check user groups
id tvheadend
# Should show: groups=... audio(29) video(44)

# Check GPU access
sudo -u tvheadend ls /dev/dri/
# Should list: card0 renderD128 (or similar)

# Test VAAPI
sudo -u tvheadend vainfo
# Should show supported codecs
```

### In TVHeadend

Record something, then check logs:
```bash
sudo journalctl -u tvheadend -f
```

Look for:
```
Stream #0:0: Video: h264_vaapi ...  # Using VAAPI!
Stream #0:0: Video: h264_nvenc ...  # Using NVENC!
```

## Performance Impact

**Example: 1080p H.264 transcoding**

| Method | CPU Usage | Encoding Speed | Quality |
|--------|-----------|----------------|---------|
| Software (x264) | 80-100% | 0.8x realtime | Reference |
| VAAPI | 10-20% | 5-10x realtime | Good |
| NVENC | 5-10% | 10-15x realtime | Excellent |
| QSV | 10-15% | 8-12x realtime | Very Good |

**Your mileage may vary** based on hardware, resolution, and settings.

## What Didn't Change

These features were already correct:
- ✅ Comskip integration
- ✅ Picons installation
- ✅ WebGrab++ setup
- ✅ Systemd integration
- ✅ Package structure

## Migration Notes

If you already installed the old package:

```bash
# Remove old package
sudo apt-get remove tvheadend-full

# Install new package
sudo dpkg -i tvheadend-full_*_amd64.deb
sudo apt-get install -f

# Install acceleration drivers
sudo apt-get install mesa-va-drivers intel-media-va-driver

# Restart service
sudo systemctl restart tvheadend

# Verify groups (should now include audio,video)
id tvheadend
```

## Additional Resources

- **VAAPI:** https://wiki.archlinux.org/title/Hardware_video_acceleration
- **NVENC:** https://developer.nvidia.com/video-encode-and-decode-gpu-support-matrix
- **Intel QSV:** https://www.intel.com/content/www/us/en/architecture-and-technology/quick-sync-video/quick-sync-video-general.html
- **TVHeadend Hardware:** https://tvheadend.org/projects/tvheadend/wiki/Transcoding

## Summary

The improvements based on the official TVHeadend Dockerfile are **significant**:

1. ⭐ **Hardware acceleration actually works** (user in video group)
2. ⭐ **Multiple acceleration methods** (VAAPI, NVENC, QSV)
3. ✅ **Better system integration** (proper directories, FHS compliant)
4. ✅ **Cleaner builds** (git safe directory, no docs)
5. ✅ **Easier maintenance** (system libraries, proper logging)

**Recommendation:** Rebuild with the new Dockerfile to get all these improvements!
