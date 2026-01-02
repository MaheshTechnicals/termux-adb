#!/data/data/com.termux/files/usr/bin/bash

# Termux ADB Uninstaller - 2026 Version
# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_LIST_FILE="$PREFIX/etc/apt/sources.list.d/termux-adb.list"
GPG_KEY_FILE="$PREFIX/etc/apt/trusted.gpg.d/nohajc.gpg"
LOG_FILE="$PREFIX/tmp/termux-adb-uninstall.log"

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Create log directory
mkdir -p "$PREFIX/tmp"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] === Termux ADB Uninstallation Started ===" > "$LOG_FILE"

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║    Termux ADB Uninstaller                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""

print_warning "This will remove termux-adb and termux-fastboot from your system."
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

# Check if package is installed
if ! dpkg -l | grep -q termux-adb; then
    print_warning "termux-adb is not installed"
else
    print_info "Removing termux-adb package..."
    if apt-get --assume-yes remove termux-adb; then
        print_success "Package removed"
    else
        print_error "Failed to remove package"
        exit 1
    fi
fi

# Remove repository configuration
if [ -f "$REPO_LIST_FILE" ]; then
    print_info "Removing repository configuration..."
    rm -f "$REPO_LIST_FILE"
    print_success "Repository configuration removed"
fi

# Remove GPG key
if [ -f "$GPG_KEY_FILE" ]; then
    print_info "Removing GPG key..."
    rm -f "$GPG_KEY_FILE"
    print_success "GPG key removed"
fi

# Update package lists
print_info "Updating package lists..."
apt-get update -qq

# Clean up
print_info "Cleaning up..."
apt-get --assume-yes autoremove -qq
apt-get --assume-yes autoclean -qq
print_success "Cleanup complete"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] === Uninstallation Completed ===" >> "$LOG_FILE"

echo ""
print_success "termux-adb has been completely uninstalled!"
print_info "Log file: $LOG_FILE"
