# Dockerfile.debian - Changelog

## Latest Fix (WebGrab++ Installation)

**Issue:** WebGrab++ config file not being created, causing build failure.

**Root Cause:** The `install.sh` script from WebGrab++ may not run properly on Debian (designed for Alpine).

**Solution Implemented:**
1. Try to run `install.sh` but don't fail if it errors (`|| true`)
2. If config file doesn't exist after install.sh, create a minimal template
3. Make config file modifications conditional (only if file exists)
4. Add verification step to show WebGrab++ files during build

**Changes Made:**
- Modified WebGrab++ download/setup step to handle install.sh failures
- Added fallback config file creation
- Made sed commands conditional on config file existence
- Added debug output to verify WebGrab++ extraction

**Testing:**
The build should now complete even if WebGrab++ install.sh fails. Users can still:
- Use all other features (TVHeadend, Comskip, Picons, etc.)
- Configure WebGrab++ manually after installation
- Install dotnet/mono and run WebGrab++ separately

**WebGrab++ Status:** 
- Included but optional
- May require manual configuration post-install
- Requires dotnet-runtime-8.0 or mono-runtime to run
- Config file: `/opt/webgrab/.wg++/WebGrab++.config.xml`

## Build Instructions

The Dockerfile.debian now handles WebGrab++ more gracefully:

```bash
# Build (will not fail if WebGrab++ has issues)
chmod +x build-tvheadend.sh
./build-tvheadend.sh

# Install
cd output
sudo dpkg -i tvheadend-full_*_amd64.deb
sudo apt-get install -f
```

## If WebGrab++ Needs Manual Setup

After installation, if WebGrab++ didn't configure properly:

```bash
# Install runtime
sudo apt-get install dotnet-runtime-8.0

# Check if config exists
ls -la /opt/webgrab/.wg++/WebGrab++.config.xml

# If missing, create minimal config
sudo tee /opt/webgrab/.wg++/WebGrab++.config.xml > /dev/null << 'EOF'
<?xml version="1.0"?>
<settings>
  <filename>/var/lib/tvheadend/webgrab/guide.xml</filename>
  <mode></mode>
  <postprocess grab="y" run="n">mdb</postprocess>
  <user-agent>Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36</user-agent>
  <logging>on</logging>
  <retry time-out="5">4</retry>
  <timespan>1</timespan>
  <update>i</update>
</settings>
EOF

# Test WebGrab++
cd /opt/webgrab/.wg++
mono WebGrab+Plus.exe
```

## Core Features (Always Work)

These features are NOT affected by the WebGrab++ issue:

✅ TVHeadend - Full functionality  
✅ Comskip - Commercial detection  
✅ Comchap/Comcut - Chapter/commercial editing  
✅ Picons - Channel icons  
⚠️ WebGrab++ - Optional, may need manual setup  

## Version Info

Current commit versions match addon-tvheadend:
- TVHeadend: 7de8bf4826b1847118f3a42556cf0afeee2a5912
- Comskip: a140b6ac8bc8f596729e9052819affc779c3b377
- Comchap: dd7db30c258e965f282ac78825971dd0703a031e
- Picons: 2025-10-17--08-28-59
- WebGrab++: v5.3.0
