# Changelog

All notable changes to termux-adb will be documented in this file.

## [2026.1] - 2026-01-02

### Added
- 🎨 **Enhanced installer** with colored output and progress indicators
- ✅ **Installation verification** - automatically verifies successful installation
- 🔒 **Security improvements** - GPG key verification with error handling
- 📝 **Comprehensive logging** - all operations logged to `$PREFIX/tmp/`
- ⚡ **Update checker** (`update.sh`) - check for and install updates
- 🗑️ **Uninstaller** (`uninstall.sh`) - complete removal with cleanup
- 🏥 **Health check tool** (`health-check.sh`) - diagnostic system check
- 🔄 **Smart reinstallation** - prompts before reinstalling existing setup
- 💾 **Better error handling** - fails fast with clear error messages
- 📊 **Dependency validation** - checks for required commands before installation
- 🚀 **Git submodule initialization** - automatically inits submodules if present

### Changed
- Updated copyright year to 2026
- Improved README with comprehensive documentation
- Enhanced bug report template with debug instructions
- Better user prompts and confirmation dialogs
- Quiet mode for apt operations (less clutter)

### Fixed
- No error handling in original install.sh (now uses `set -euo pipefail`)
- Missing installation verification
- No security checks for downloaded files
- Empty git submodule not initialized
- Hardcoded values now use variables
- Missing progress feedback during installation

### Security
- Added GPG key verification
- Added download timeout for security
- Added error handling for failed downloads
- Automatic cleanup on failed installation

## [Original] - 2022

### Added
- Initial release
- Basic installation script
- Modified ADB and Fastboot for Termux
- USB device access without root via termux-usb
- Documentation and build instructions
