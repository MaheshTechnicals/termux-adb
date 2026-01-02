#!/data/data/com.termux/files/usr/bin/bash

# Termux ADB Update Checker - 2026 Version
# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║    Termux ADB Update Checker              ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Check if termux-adb is installed
if ! command -v termux-adb &> /dev/null; then
    print_error "termux-adb is not installed"
    print_info "Run ./install.sh to install"
    exit 1
fi

# Get current version
print_info "Checking current version..."
CURRENT_VERSION=$(termux-adb version 2>/dev/null | head -n1 || echo "unknown")
echo "  Current version: $CURRENT_VERSION"

# Update package lists
print_info "Checking for updates..."
apt-get update -qq

# Check if update is available
if apt list --upgradable 2>/dev/null | grep -q termux-adb; then
    AVAILABLE_VERSION=$(apt-cache policy termux-adb | grep Candidate | awk '{print $2}')
    echo ""
    print_warning "Update available!"
    echo "  Available version: $AVAILABLE_VERSION"
    echo ""
    read -p "Do you want to update now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating termux-adb..."
        if apt-get --assume-yes install termux-adb; then
            NEW_VERSION=$(termux-adb version 2>/dev/null | head -n1 || echo "unknown")
            print_success "Update complete!"
            echo "  New version: $NEW_VERSION"
        else
            print_error "Update failed"
            exit 1
        fi
    else
        print_info "Update cancelled"
    fi
else
    print_success "You are already running the latest version!"
fi

echo ""
print_info "Update check complete"
