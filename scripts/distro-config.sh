#!/bin/bash
# Distro-specific configuration for package building
# This file should be sourced by copy-output.sh

# Default values (Debian)
DISTRO="${DISTRO:-Debian}"
DISTRO_BASE="${DISTRO_BASE:-Debian Base: bookworm}"
PACKAGE_EXT="${PACKAGE_EXT:-.deb}"
INSTALL_CMD="${INSTALL_CMD:-sudo dpkg -i}"
INSTALL_DEPS_CMD="${INSTALL_DEPS_CMD:-sudo apt-get install -f}"

# Example configurations for other distros (commented out):
#
# For Ubuntu:
# DISTRO="Ubuntu"
# DISTRO_BASE="Ubuntu Base: jammy"
# PACKAGE_EXT=".deb"
# INSTALL_CMD="sudo dpkg -i"
# INSTALL_DEPS_CMD="sudo apt-get install -f"
#
# For Fedora/RHEL (future):
# DISTRO="Fedora"
# DISTRO_BASE="Fedora Base: 39"
# PACKAGE_EXT=".rpm"
# INSTALL_CMD="sudo dnf install"
# INSTALL_DEPS_CMD="sudo dnf install"
#
# For Arch (future):
# DISTRO="Arch Linux"
# DISTRO_BASE="Arch Base: current"
# PACKAGE_EXT=".pkg.tar.zst"
# INSTALL_CMD="sudo pacman -U"
# INSTALL_DEPS_CMD="sudo pacman -S"
