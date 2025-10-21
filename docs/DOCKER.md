# TVHeadend Docker Container

This document describes how to use the TVHeadend Docker container with hardware acceleration support.

## Quick Start

### Using Docker Run

```bash
docker run -d \
  --name tvheadend \
  -p 9981:9981 \
  -p 9982:9982 \
  -v /path/to/config:/var/lib/tvheadend \
  -v /path/to/recordings:/recordings \
  --device /dev/dri:/dev/dri \
  rknall/tvheadend-hwaccel:latest
```

### Using Docker Compose

```bash
# Download the docker-compose.yml
curl -O https://raw.githubusercontent.com/rknall/TVHBuilder/main/docker-compose.yml

# Edit configuration
nano docker-compose.yml

# Start container
docker compose up -d

# View logs
docker compose logs -f

# Stop container
docker compose down
```

## Container Details

### Image Information

- **Image Name**: `rknall/tvheadend-hwaccel`
- **Architectures**: `linux/amd64`, `linux/arm64`
- **Base**: Debian Bookworm Slim
- **Size**: ~500-600 MB

### Included Components

- **TVHeadend**: Main TV streaming server
- **Comskip**: Commercial detection
- **Comchap/Comcut**: Commercial removal scripts
- **Picons**: Channel icons (SNP and SRP formats)
- **WebGrab++**: EPG grabber (with .NET 8.0 runtime)

### Hardware Acceleration Support

The container includes drivers for:
- **VAAPI** - Intel/AMD GPU acceleration
- **NVENC** - NVIDIA GPU encoding
- **QSV** - Intel Quick Sync Video
- **VDPAU** - NVIDIA video decoding

## Configuration

### Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 9981 | HTTP | Web interface |
| 9982 | TCP | HTSP streaming protocol |

### Volumes

| Container Path | Purpose | Required |
|----------------|---------|----------|
| `/var/lib/tvheadend` | Configuration and database | Yes |
| `/recordings` | Recording storage | Recommended |
| `/opt/picons` | Channel icons | No |
| `/etc/comskip` | Comskip configuration | No |
| `/var/lib/tvheadend/webgrab` | WebGrab++ EPG data | No |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | UTC | Timezone (e.g., `Europe/Vienna`) |
| `PUID` | 9981 | User ID for file ownership |
| `PGID` | 9981 | Group ID for file ownership |

### Device Mapping

#### Intel/AMD GPU (VAAPI)
```yaml
devices:
  - /dev/dri:/dev/dri
```

#### NVIDIA GPU (with nvidia-docker)
```yaml
runtime: nvidia
devices:
  - /dev/nvidia0:/dev/nvidia0
  - /dev/nvidiactl:/dev/nvidiactl
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,video,utility
```

#### DVB Adapters
```yaml
devices:
  - /dev/dvb:/dev/dvb
```

## First Run

1. **Start the container**:
   ```bash
   docker compose up -d
   ```

2. **Access web interface**:
   - URL: `http://localhost:9981`
   - Default credentials: `admin` / `admin`
   - **IMPORTANT**: Change password immediately!

3. **Configure TVHeadend**:
   - Add tuners/adapters
   - Configure networks and muxes
   - Set up recording profiles
   - Enable hardware acceleration in stream profiles

## Hardware Acceleration Setup

### Intel/AMD (VAAPI)

1. Ensure `/dev/dri` devices are mapped
2. In TVHeadend web interface:
   - Configuration → Recording → Stream Profiles
   - Select profile → Transcoding
   - Set Video Codec: `libx264` or `h264_vaapi`
   - Set Hardware Acceleration: `vaapi`

### NVIDIA (NVENC)

1. Install nvidia-docker on host
2. Add runtime and devices to docker-compose.yml
3. In TVHeadend:
   - Set Video Codec: `h264_nvenc` or `hevc_nvenc`
   - Hardware acceleration will be used automatically

## Building the Container

### Local Build

```bash
# Build for current architecture
./build-tvheadend.sh --docker

# Build with no cache
./build-tvheadend.sh --docker --clean
```

### Multi-Architecture Build

```bash
# Setup buildx
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# Build for both amd64 and arm64
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t rknall/tvheadend-hwaccel:latest \
  -f Dockerfile.docker \
  --push \
  .
```

## Troubleshooting

### No GPU Acceleration

**Check device access**:
```bash
docker exec tvheadend ls -la /dev/dri
```

**Verify user groups**:
```bash
docker exec tvheadend id hts
# Should show: video, audio, render groups
```

### Permission Issues

**Fix volume permissions**:
```bash
sudo chown -R 9981:9981 /path/to/config
sudo chown -R 9981:9981 /path/to/recordings
```

### Container Won't Start

**Check logs**:
```bash
docker logs tvheadend
# or
docker compose logs
```

### DVB Adapters Not Found

**Option 1**: Use host network mode
```yaml
network_mode: host
```

**Option 2**: Add privileged mode
```yaml
privileged: true
```

**Option 3**: Map specific devices
```yaml
devices:
  - /dev/dvb/adapter0:/dev/dvb/adapter0
  - /dev/dvb/adapter1:/dev/dvb/adapter1
```

## Updates

### Pull Latest Image

```bash
docker compose pull
docker compose up -d
```

### Update Specific Version

```bash
docker pull rknall/tvheadend-hwaccel:v1.0.0
# Update docker-compose.yml to use version tag
docker compose up -d
```

## Advanced Configuration

### Custom Picons

```bash
# Download picons to host
mkdir -p ./picons

# Mount in docker-compose.yml
volumes:
  - ./picons:/opt/picons:ro
```

### WebGrab++ EPG Configuration

```bash
# Create WebGrab++ config directory
mkdir -p ./webgrab

# Add your WebGrab++.config.xml
cp WebGrab++.config.xml ./webgrab/

# Mount in docker-compose.yml
volumes:
  - ./webgrab:/opt/webgrab/.wg++
```

### Comskip Configuration

```bash
# Create comskip config
mkdir -p ./comskip
nano ./comskip/comskip.ini

# Mount in docker-compose.yml
volumes:
  - ./comskip:/etc/comskip
```

## Container Registries

The image is available from multiple registries:

- **Docker Hub**: `docker pull rknall/tvheadend-hwaccel:latest`
- **GitHub Container Registry**: `docker pull ghcr.io/rknall/tvheadend-hwaccel:latest`
- **GitLab Container Registry**: `docker pull registry.gitlab.com/rknall/tvhbuilder:latest`

All registries contain the same multi-architecture images.

## Security Considerations

1. **Change default password** immediately after first login
2. **Use read-only volumes** where possible (`:ro` flag)
3. **Avoid privileged mode** unless absolutely necessary
4. **Limit network exposure** with firewall rules
5. **Keep container updated** regularly

## Performance Optimization

### CPU Transcoding

If no GPU available, optimize CPU usage:
```yaml
environment:
  - TVH_THREADS=4  # Limit transcoding threads
```

### Storage Performance

Use fast storage for recordings:
- SSD/NVMe for recordings
- HDD for archives
- Network storage for backups

### Memory Limits

Set memory limits in docker-compose.yml:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 512M
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/rknall/TVHBuilder/issues
- TVHeadend Forums: https://tvheadend.org/projects/tvheadend/boards
- Docker Hub: https://hub.docker.com/r/rknall/tvheadend-hwaccel
