# termux-adb

Run adb and fastboot in Termux without root permissions!

[![Version](https://img.shields.io/badge/version-2026-blue.svg)](https://github.com/MaheshTechnicals/termux-adb/tree/mt)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Description

This is a modified version of adb and fastboot which enables debugging of one Android device from another via USB cable.
It should work with any USB-C male-to-male cable or the corresponding OTG adapter + cable in case of micro USB.

## Features ✨

- 🔧 Root-free ADB and Fastboot for Termux
- 🎨 Enhanced installer with colored output (2026)
- ✅ Automatic installation verification
- 🔒 GPG signature verification for security
- 📝 Comprehensive logging
- ⚡ Smart update checking
- 🗑️ Easy uninstallation

## Prerequisites

- Termux from [F-Droid](https://f-droid.org/packages/com.termux/)
- Termux:API from [F-Droid](https://f-droid.org/packages/com.termux.api/)
- USB-C cable or OTG adapter + USB cable
- Android device with USB debugging enabled

## Installation

### Quick Install (Recommended)

```bash
curl -s https://raw.githubusercontent.com/MaheshTechnicals/termux-adb/mt/install.sh | bash
```

### Manual Install

```bash
# Clone repository
git clone -b mt https://github.com/MaheshTechnicals/termux-adb.git
cd termux-adb

# Make scripts executable
chmod +x install.sh uninstall.sh update.sh

# Run installer
./install.sh
```

### What the installer does:
- ✓ Checks system requirements
- ✓ Updates package lists
- ✓ Installs dependencies (coreutils, gnupg, wget, curl)
- ✓ Adds termux-adb apt repository
- ✓ Installs GPG key for package verification
- ✓ Installs `termux-adb` and `termux-fastboot`
- ✓ Verifies installation
- ✓ Creates detailed log file

## Updating

### Check for Updates

```bash
./update.sh
```

### Automatic Update via Package Manager

```bash
pkg upgrade
```

Any future upgrades will be done automatically as part of `pkg upgrade`.

## Uninstallation

```bash
./uninstall.sh
```

This will:
- Remove termux-adb package
- Remove repository configuration
- Remove GPG key
- Clean up dependencies

## Usage

Both `termux-adb` and `termux-fastboot` are drop-in replacements for the original commands so the usage is exactly the same.
The commands were only renamed to avoid collision with the official `android-tools` Termux package (which contains more tools beside these two).

### Basic Commands

```bash
# Check version
termux-adb version

# List connected devices
termux-adb devices

# Connect to device
termux-adb shell

# Install APK
termux-adb install app.apk

# Push/Pull files
termux-adb push local.txt /sdcard/
termux-adb pull /sdcard/file.txt

# Fastboot mode
termux-fastboot devices
termux-fastboot flash recovery recovery.img
```

### Logs and Debugging

Installation and runtime logs are stored in:
```bash
$PREFIX/tmp/termux-adb-install.log
$PREFIX/tmp/termux-adb.*.log
```

For debug output:
```bash
RUST_LOG=debug termux-adb devices
```

## Troubleshooting

### Common Issues

**Device not detected:**
- Ensure USB debugging is enabled on the target device
- Check if `termux-usb` has permission to access the USB device
- Try disconnecting and reconnecting the USB cable
- Grant USB permission when prompted

**Installation fails:**
- Check internet connection
- Verify Termux has storage permission
- Check logs in `$PREFIX/tmp/termux-adb-install.log`
- Try running: `pkg update && pkg upgrade` first

**Commands not found after installation:**
- Close and reopen Termux
- Check if installed: `which termux-adb`
- Verify PATH: `echo $PATH`

### Getting Help

If you encounter issues:
1. Check the log files in `$PREFIX/tmp/`
2. Run with debug logging: `RUST_LOG=debug termux-adb`
3. Open an issue with:
   - Output of `termux-adb version`
   - Output of `pkg show termux-adb`
   - Relevant log files
   - Device and Android version

## Build Instructions

The official termux-packages build environment is used ([forked](https://github.com/nohajc/termux-packages) to add the `termux-adb` package).

For more information, please refer to the Termux documentation:
- https://github.com/termux/termux-packages/wiki/Build-environment
- https://github.com/termux/termux-packages/wiki/Building-packages

## Current limitations

Using `termux-usb` and querying device serial number with `libusb` tends to be slow. That's not a problem for adb which runs as a daemon and scans USB devices periodically. However, it is quite noticeable for `termux-fastboot` commands because fastboot doesn't use any background service. This can potentially be improved in a future release.

## How it actually works

Termux has the `android-tools` package which contains `adb` and `fastboot` but it normally works on rooted devices only.
This is mainly due to filesystem permissions required by adb when enumerating USB devices (traversing `/dev/bus/usb/*`).

There is, however, Android API exposed by `termux-usb` utility which gives you a raw file descriptor of any connected USB device after manual approval by the user.

Of course, `adb` by itself doesn't know anything about `termux-usb` nor it can take raw file descriptors from command-line or environment.
If it cannot access `/dev/bus/usb`, it just won't detect any connected devices. This is where `termux-adb` comes in.

Both `adb` and `fastboot` are patched to scan for USB devices using the `termux-usb` command. Furthermore a Unix Domain Socket is used to transfer the obtained file descriptors from child process to the parent (i.e. `termux-adb` runs `termux-usb` for every detected device which in turn runs `termux-adb` in a special mode that will only send USB file descriptor to the UDS file descriptor provided by environment variable).

This way we don't complicate the user experience and we can work with any number of devices connected at once (e.g. if you have a USB hub connected to the OTG adapter).

## Additional Tools 🛠️

### Health Check
Check system status and diagnose issues:
```bash
./health-check.sh
```

This will verify:
- Installation status
- Dependencies
- Repository configuration
- USB device detection
- ADB device connections
- Permissions and logs

### Update Checker
Check for and install updates:
```bash
./update.sh
```

### Uninstaller
Complete removal of termux-adb:
```bash
./uninstall.sh
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original project by [nohajc](https://github.com/nohajc)
- Built on top of [termux-packages](https://github.com/termux/termux-packages)
- Uses patched Android platform tools

## Support

- 📝 [Report Issues](https://github.com/MaheshTechnicals/termux-adb/issues)
- 💬 [Discussions](https://github.com/MaheshTechnicals/termux-adb/discussions)
- 📖 [Wiki](https://github.com/MaheshTechnicals/termux-adb/wiki)

---

**Made with ❤️ for the Termux community**
