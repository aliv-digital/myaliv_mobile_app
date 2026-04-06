# Changelog

All notable changes to the core package will be documented in this file.

## [1.0.0] - 2026-01-19

### Added
- Initial package structure
- Base controller with error handling
- HTTP service configuration with debugPrint logging
- Common utilities and extensions
- Shared models and constants
- Reusable widgets
- Core services (navigation, storage)

### Structure
- Created modular package architecture
- Organized code by feature/type
- Set up proper exports
- Added comprehensive documentation

### Best Practices
- Implemented debugPrint() instead of print() across all logging
- Added logging guidelines to documentation
- DioService uses debugPrint() for all HTTP request/response/error logging
