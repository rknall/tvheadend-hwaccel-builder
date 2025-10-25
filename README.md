# TVHeadend Hardware Acceleration Packages

This repository provides Debian packages for TVHeadend with hardware acceleration support (VAAPI, NVENC, QSV).

## Installation

Add the repository to your system:

```bash
# Add the repository
echo "deb [trusted=yes] https://$(echo rknall/tvheadend-hwaccel-builder | cut -d'/' -f1).github.io/$(echo rknall/tvheadend-hwaccel-builder | cut -d'/' -f2)/debian/ stable main" | sudo tee /etc/apt/sources.list.d/tvheadend-hwaccel.list

# Update package list
sudo apt-get update
```

## Available Packages

- **tvheadend** - Core TV streaming server
- **tvheadend-comskip** - Commercial detection tools
- **tvheadend-picons** - Channel icons
- **tvheadend-webgrab** - EPG grabber
- **tvheadend-full** - Meta-package (installs all components)

## Install Options

### Full Installation
```bash
sudo apt-get install tvheadend-full
```

### Core Only
```bash
sudo apt-get install tvheadend
```

### Custom Selection
```bash
sudo apt-get install tvheadend tvheadend-comskip tvheadend-picons
```

## Manual Download

You can also download .deb files directly from the [Releases](https://github.com/rknall/tvheadend-hwaccel-builder/releases) page.
