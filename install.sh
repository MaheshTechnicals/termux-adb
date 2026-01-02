#!/data/data/com.termux/files/usr/bin/bash

# Termux ADB Installer - 2026 Enhanced Version
# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Color codes for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://nohajc.github.io"
GPG_KEY_URL="$REPO_URL/nohajc.gpg"
REPO_LIST_FILE="$PREFIX/etc/apt/sources.list.d/termux-adb.list"
LOG_FILE="$PREFIX/tmp/termux-adb-install.log"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
    log "INFO: $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
    log "ERROR: $1"
}

# Error handler
error_handler() {
    print_error "Installation failed at line $1"
    print_info "Check log file: $LOG_FILE"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Create log directory
mkdir -p "$PREFIX/tmp"
log "=== Termux ADB Installation Started ==="

# Check for required commands
print_info "Checking system requirements..."
for cmd in curl wget; do
    if ! command -v $cmd &> /dev/null; then
        print_warning "$cmd not found, will be installed"
    fi
done

# Update package lists
print_info "Updating package lists..."
apt-get update -qq || {
    print_error "Failed to update package lists"
    exit 1
}
print_success "Package lists updated"

# Upgrade existing packages
print_info "Upgrading existing packages..."
apt-get --assume-yes upgrade -qq
print_success "Packages upgraded"

# Install dependencies
print_info "Installing dependencies..."
apt-get --assume-yes install coreutils gnupg wget curl -qq
print_success "Dependencies installed"

# Check if repo is already configured
if [ -f "$REPO_LIST_FILE" ]; then
    print_warning "Repository already configured"
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating termux-adb..."
        apt-get update -qq
        apt-get --assume-yes install termux-adb
        print_success "termux-adb updated successfully!"
        exit 0
    fi
    print_info "Removing existing configuration..."
    rm -f "$REPO_LIST_FILE"
fi

# Create repository directory
mkdir -p "$PREFIX/etc/apt/sources.list.d"
mkdir -p "$PREFIX/etc/apt/trusted.gpg.d"

# Add repository
print_info "Adding termux-adb repository..."
echo "deb $REPO_URL termux extras" > "$REPO_LIST_FILE"
print_success "Repository added"

# Download and verify GPG key
print_info "Downloading GPG key..."
if wget -q --timeout=30 -O "$PREFIX/etc/apt/trusted.gpg.d/nohajc.gpg" "$GPG_KEY_URL"; then
    print_success "GPG key installed"
else
    print_error "Failed to download GPG key"
    rm -f "$REPO_LIST_FILE"
    exit 1
fi

# Update package lists with new repository
print_info "Updating package lists with new repository..."
apt-get update -qq || {
    print_error "Failed to update from new repository"
    rm -f "$REPO_LIST_FILE"
    rm -f "$PREFIX/etc/apt/trusted.gpg.d/nohajc.gpg"
    exit 1
}

# Install termux-adb
print_info "Installing termux-adb and termux-fastboot..."
if apt-get --assume-yes install termux-adb; then
    print_success "termux-adb installed successfully!"
else
    print_error "Failed to install termux-adb"
    exit 1
fi

# Verify installation
print_info "Verifying installation..."
if command -v termux-adb &> /dev/null && command -v termux-fastboot &> /dev/null; then
    ADB_VERSION=$(termux-adb version 2>/dev/null | head -n1 || echo "unknown")
    print_success "Installation verified!"
    print_info "ADB Version: $ADB_VERSION"
else
    print_warning "Installation completed but commands not found in PATH"
    print_info "Try closing and reopening Termux"
fi

# Initialize git submodule if in git repository
if [ -d ".git" ] && [ -f ".gitmodules" ]; then
    print_info "Initializing git submodules..."
    if command -v git &> /dev/null; then
        git submodule update --init --recursive 2>/dev/null || print_warning "Could not initialize submodules"
    fi
fi

log "=== Installation Completed Successfully ==="
echo ""
print_success "Installation complete!"
print_info "You can now use: termux-adb and termux-fastboot"
print_info "Run 'termux-adb --help' for usage information"
print_info "Log file: $LOG_FILE"
