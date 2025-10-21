# Custom Libraries Directory

This directory is for providing custom-built FFmpeg and codec library packages to be bundled into the TVHeadend packages.

## Purpose

Use this directory when you want to:
- Use a newer/custom version of FFmpeg
- Include specific codec versions
- Bundle all dependencies for self-contained packages

## How It Works

1. Place custom `.deb` packages in this directory
2. Run the build: `./build-tvheadend.sh`
3. Build system automatically detects and uses custom libraries
4. Libraries are bundled into the final tvheadend package

## Expected Packages

Place your custom-built `.deb` files here. Typical packages include:

### Required
- `ffmpeg_*.deb` - FFmpeg binaries (ffmpeg, ffprobe)
- `libavcodec-dev_*.deb` or `libavcodec59_*.deb` - Video/audio codec library
- `libavformat-dev_*.deb` or `libavformat59_*.deb` - Container format library
- `libavutil-dev_*.deb` or `libavutil57_*.deb` - Utility library
- `libavfilter-dev_*.deb` or `libavfilter8_*.deb` - Filter library
- `libswscale-dev_*.deb` or `libswscale6_*.deb` - Scaling library
- `libswresample-dev_*.deb` or `libswresample4_*.deb` - Resampling library

### Optional (codec libraries)
- `libx264-*.deb` - H.264 encoder
- `libx265-*.deb` - H.265/HEVC encoder
- `libvpx-*.deb` - VP8/VP9 encoder
- `libopus*.deb` - Opus audio codec
- `libvorbis*.deb` - Vorbis audio codec
- `libtheora*.deb` - Theora video codec

## Source Location (for nextpvr build server)

On the nextpvr build machine, custom packages are located at:
```bash
/opt/build/packages/
```

To set up for build:
```bash
cd /path/to/TVHBuilder
mkdir -p custom-libs
cp /opt/build/packages/*.deb custom-libs/
```

## What Gets Bundled

When custom libraries are detected, the build will bundle:
- FFmpeg binaries (`/usr/bin/ffmpeg`, `/usr/bin/ffprobe`)
- All `libav*` shared libraries
- All codec shared libraries (libx264, libx265, libvpx, etc.)

These are copied into the tvheadend package under `/usr/lib/x86_64-linux-gnu/`.

## Impact

### Package Size
- **Without custom libs**: tvheadend core ~10-15MB
- **With custom libs**: tvheadend core ~60-90MB (includes FFmpeg + codecs)

### Dependencies
When custom libraries are bundled:
- External FFmpeg/codec dependencies are removed
- Package is self-contained
- No need to install system FFmpeg separately

### Compatibility
- Custom libraries must match the architecture (amd64, arm64)
- Built for Debian Bookworm or compatible
- Include all runtime dependencies

## Verification

After building, verify custom libraries are bundled:
```bash
# List bundled libraries
dpkg-deb -c output/tvheadend_*.deb | grep -E "(libav|ffmpeg|libx26)"

# Check package size
ls -lh output/tvheadend_*.deb

# Verify dependencies don't include libavcodec, etc.
dpkg-deb -I output/tvheadend_*.deb | grep Depends
```

## Fallback Behavior

If this directory is empty or contains no `.deb` files:
- Build uses system packages from Debian repositories
- Standard behavior (current default)
- Smaller package size, external dependencies

## Notes

- `.deb` files are gitignored (too large for version control)
- Only this README is tracked in git
- Architecture-specific: amd64 packages for amd64 builds, arm64 for arm64 builds
