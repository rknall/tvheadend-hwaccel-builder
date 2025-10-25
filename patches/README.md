# TVHeadend Patches

This directory contains patches that are applied to TVHeadend source code before compilation.

## How It Works

1. Place `.patch` files in this directory
2. During Docker build, patches are automatically applied after checking out the TVHeadend commit
3. Patches are applied in alphabetical order
4. Build fails if any patch cannot be applied

## Current Patches

### fix-vaapi-transcoding-issue-1963.patch

**Issue:** https://github.com/tvheadend/tvheadend/issues/1963

**Description:** Fixes VAAPI transcoding breakage introduced in commit 0af87f1. The patch corrects time base handling for hardware-accelerated deinterlacing filters.

**Changes:**
- Replaces `AVFilterLink` usage with computed `src_time_base`
- Adds version-specific handling for FFmpeg 4.x-5.x vs 6.x+
- Fixes frame duration and timestamp rescaling for VAAPI filters

**Status:** Required for VAAPI transcoding with deinterlacing

## Adding New Patches

To add a new patch:

1. Create a `.patch` file in this directory using standard unified diff format
2. Name it descriptively (e.g., `fix-issue-number-description.patch`)
3. The patch will be automatically applied on next build
4. Document it in this README

## Creating Patches

If you need to create a patch from TVHeadend source:

```bash
cd /path/to/tvheadend
# Make your changes
git diff > /path/to/TVHBuilder/patches/my-fix.patch
```

## Removing Patches

To stop applying a patch, simply delete or rename the `.patch` file (e.g., add `.disabled` extension).
