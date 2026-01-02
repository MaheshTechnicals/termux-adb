#!/data/data/com.termux/files/usr/bin/bash

# Termux ADB Health Check - 2026 Version
# Diagnostic tool to check system status

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     Termux ADB Health Check Diagnostic     ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}▶${NC} ${CYAN}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

print_header

# Check Termux installation
print_section "System Information"
echo "Date: $(date)"
echo "Termux Version: $(termux-info | grep TERMUX_VERSION | cut -d'=' -f2 || echo 'unknown')"
echo "Android Version: $(getprop ro.build.version.release || echo 'unknown')"
echo "Device: $(getprop ro.product.model || echo 'unknown')"
echo ""

# Check termux-adb installation
print_section "Package Status"
if command -v termux-adb &> /dev/null; then
    check_status 0 "termux-adb is installed"
    echo "  Version: $(termux-adb version 2>/dev/null | head -n1 || echo 'unknown')"
else
    check_status 1 "termux-adb is NOT installed"
fi

if command -v termux-fastboot &> /dev/null; then
    check_status 0 "termux-fastboot is installed"
else
    check_status 1 "termux-fastboot is NOT installed"
fi
echo ""

# Check dependencies
print_section "Dependencies"
for cmd in curl wget gnupg termux-usb; do
    if command -v $cmd &> /dev/null; then
        check_status 0 "$cmd is available"
    else
        check_status 1 "$cmd is missing"
    fi
done
echo ""

# Check repository configuration
print_section "Repository Configuration"
REPO_FILE="$PREFIX/etc/apt/sources.list.d/termux-adb.list"
GPG_FILE="$PREFIX/etc/apt/trusted.gpg.d/nohajc.gpg"

if [ -f "$REPO_FILE" ]; then
    check_status 0 "Repository is configured"
    echo "  Location: $REPO_FILE"
else
    check_status 1 "Repository is NOT configured"
fi

if [ -f "$GPG_FILE" ]; then
    check_status 0 "GPG key is installed"
else
    check_status 1 "GPG key is missing"
fi
echo ""

# Check USB devices
print_section "USB Devices"
if command -v termux-usb &> /dev/null; then
    USB_DEVICES=$(termux-usb -l 2>/dev/null || echo "")
    if [ -n "$USB_DEVICES" ]; then
        check_status 0 "USB devices detected"
        echo "$USB_DEVICES" | while read line; do
            echo "  $line"
        done
    else
        check_status 1 "No USB devices detected"
    fi
else
    check_status 1 "termux-usb not available"
fi
echo ""

# Check ADB devices
print_section "ADB Devices"
if command -v termux-adb &> /dev/null; then
    ADB_DEVICES=$(termux-adb devices 2>/dev/null | tail -n +2 | grep -v "^$" || echo "")
    if [ -n "$ADB_DEVICES" ]; then
        check_status 0 "ADB devices connected"
        echo "$ADB_DEVICES" | while read line; do
            echo "  $line"
        done
    else
        check_status 1 "No ADB devices connected"
    fi
else
    check_status 1 "termux-adb not available"
fi
echo ""

# Check permissions
print_section "Permissions"
if [ -r "$PREFIX" ]; then
    check_status 0 "Termux prefix is readable"
else
    check_status 1 "Cannot read Termux prefix"
fi

if [ -w "$PREFIX/tmp" ]; then
    check_status 0 "Temp directory is writable"
else
    check_status 1 "Cannot write to temp directory"
fi
echo ""

# Check logs
print_section "Log Files"
for log in "$PREFIX/tmp/termux-adb-install.log" "$PREFIX/tmp/termux-adb.*.log"; do
    if ls $log 2>/dev/null | grep -q .; then
        echo -e "${GREEN}✓${NC} Found: $log"
    fi
done
echo ""

# Summary
print_section "Summary"
if command -v termux-adb &> /dev/null && [ -f "$REPO_FILE" ]; then
    echo -e "${GREEN}✓ System is healthy and ready to use!${NC}"
else
    echo -e "${YELLOW}⚠ System needs attention. Run ./install.sh to fix.${NC}"
fi
echo ""
