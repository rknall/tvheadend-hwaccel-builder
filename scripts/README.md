# TVHeadend Full - Utility Scripts

## cleanup.sh

Complete cleanup script for removing TVHeadend Full installation.

### Usage

```bash
sudo ./scripts/cleanup.sh
```

### What it does

The cleanup script performs a complete removal of TVHeadend Full including:

1. **Service Management**
   - Stops the TVHeadend service if running
   - Disables the systemd service
   - Removes the service file

2. **Package Removal**
   - Purges the tvheadend-full package

3. **Binary Cleanup**
   - Removes tvheadend, comskip, comchap, comcut, tv_grab_wg++

4. **Configuration Removal**
   - Removes /etc/tvheadend
   - Removes /etc/comskip
   - Removes /etc/default/tvheadend

5. **Data and Logs**
   - Removes /var/lib/tvheadend (includes recordings!)
   - Removes /var/log/tvheadend

6. **Additional Tools**
   - Removes /opt/picons
   - Removes /opt/webgrab

7. **User Management**
   - Removes hts user from audio, video, render groups
   - Deletes the hts user and group
   - Removes home directory

8. **System Cleanup**
   - Purges debconf database entries
   - Runs apt-get autoremove and autoclean

### Failsafe Features

- **Root check**: Requires sudo/root privileges
- **Confirmation prompt**: Asks for explicit 'yes' before proceeding
- **Non-fatal errors**: Uses `set +e` to continue even if steps fail
- **Existence checks**: Verifies files/directories exist before removal
- **Service checks**: Verifies service is active/enabled before stopping
- **User checks**: Verifies user/group exists before deletion
- **Safe to rerun**: Can be executed multiple times without errors

### Warning

This script will permanently delete:
- All recordings in /var/lib/tvheadend/recordings
- All configuration in /var/lib/tvheadend
- All logs in /var/log/tvheadend

Make sure to backup any important data before running!

### Example Output

```
========================================
TVHeadend Full - Complete Cleanup
========================================

WARNING: This will completely remove TVHeadend Full and all its data!
Are you sure you want to continue? (yes/no): yes

[1/10] Stopping TVHeadend service
  Stopping service... done
  Disabling service... done
[2/10] Removing systemd service files
  Removing service file... done
  Reloading systemd... done
...
[10/10] Cleaning up debconf database
  Debconf entries purged

========================================
Cleanup complete!
========================================
```
