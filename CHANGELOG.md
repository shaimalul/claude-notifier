# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive unit test suite
- CI/CD pipeline with GitHub Actions
- SwiftLint and SwiftFormat configuration
- Contributing guidelines
- Security policy
- Code of Conduct

### Changed
- Restructured codebase into Sources/ directory
- Extracted shared Logger utility
- Centralized configuration in AppConfig
- Split HTTPServer into smaller modules

### Fixed
- Removed duplicate logging code across files

## [1.0.0] - 2024-01-22

### Added
- Initial public release
- Native macOS notifications for Claude Code events
- Click-to-focus functionality for Cursor windows
- HTTP server on port 19847
- Claude Code plugin integration with hooks
- One-command installation script
- Auto-start on login
- Accessibility API integration for window management
