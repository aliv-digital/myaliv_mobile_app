# Core Package

A reusable Flutter package containing shared networking, utilities, and services for the HRMS application and beyond.

## Overview

The `core` package provides a generic, production-ready networking layer and utilities that can be used across multiple Flutter projects. It's designed to be framework-agnostic with app-specific integration through callbacks.

## Features

### 🌐 NetworkService

A comprehensive HTTP client wrapper built on Dio with:

- ✅ **Uses `debugPrint()` throughout** - No `print()` statements
- ✅ **Custom exception types** - `SessionExpiredException`, `NoInternetException`, `TimeoutException`, `ServerException`
- ✅ **Request cancellation** - Cancel individual or all requests
- ✅ **Progress tracking** - Upload/download progress callbacks
- ✅ **Type-safe requests** - Generic response types
- ✅ **Session management** - Cookie handling, session validation
- ✅ **Auto-retry logic** - Configurable retry attempts
- ✅ **Structured logging** - Beautiful, formatted debug logs

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  core:
    path: packages/core
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize NetworkService

Create an app-specific initialization file that bridges the core package with your app's dependencies:

```dart
// lib/core/network/network_init.dart
import 'package:core/core.dart';

Future<void> initNetworkService() async {
  await NetworkService.instance.init(
    config: NetworkConfig(
      baseUrl: 'https://api.example.com',
      enableLogging: kDebugMode,
    ),
    callbacks: NetworkCallbacks(
      // Get auth token from your storage
      getAuthToken: () async {
        return await YourStorage.getToken();
      },

      // Handle session expiration
      onSessionExpired: () async {
        // Clear data and navigate to login
        await YourStorage.clear();
        Navigator.pushReplacement(...);
      },

      // Handle session cookie
      onSessionCookie: (sessionId) async {
        // Save session ID if needed
        await YourStorage.saveSessionId(sessionId);
      },
    ),
  );
}
```

### 2. Use in Your App

```dart
// Import from core package
import 'package:core/core.dart';

// Make requests using helper functions
Future<void> fetchUsers() async {
  try {
    final response = await get('/users');
    // Handle response
  } on NoInternetException {
    showSnackBar('No internet connection');
  } on TimeoutException {
    showSnackBar('Request timeout');
  } on NetworkException catch (e) {
    showSnackBar('Error: ${e.message}');
  }
}

// Upload file with progress
await uploadFile(
  '/upload',
  data: {'title': 'My File'},
  files: [MapEntry('file', multipartFile)],
  onProgress: (sent, total) {
    print('Progress: ${(sent/total*100).toFixed(0)}%');
  },
);

// Download file with progress
await downloadFile(
  '/files/document.pdf',
  savePath,
  onProgress: (received, total) {
    print('Download: ${(received/total*100).toFixed(0)}%');
  },
);
```

## Architecture

### Generic Core Package

The core package is designed to be generic and reusable:

- **No app-specific dependencies** - Uses callbacks for app integration
- **Framework-agnostic** - Can work with GetX, Provider, Riverpod, etc.
- **Clean separation** - Business logic in core, app-specific in callbacks

### App Integration

Your app provides the specific implementation through callbacks:

```dart
NetworkCallbacks(
  getAuthToken: () => YourAuthService.getToken(),
  onSessionExpired: () => YourAuthService.logout(),
  onSessionCookie: (id) => YourStorage.saveSession(id),
)
```

## API Reference

### NetworkService

```dart
// Initialize
await NetworkService.instance.init(
  config: NetworkConfig(...),
  callbacks: NetworkCallbacks(...),
);

// Make requests
final response = await NetworkService.instance.request(
  '/path',
  method: HttpMethod.get,
);

// Cancel requests
NetworkService.instance.cancelRequest('request-id');
NetworkService.instance.cancelAllRequests();

// Check session
final hasSession = await NetworkService.instance.hasValidSession(url);

// Clear cookies
await NetworkService.instance.clearCookies();
```

### Helper Functions

```dart
// GET request
await get('/users', queryParameters: {'page': 1});

// POST request
await post('/login', data: {'email': 'test@example.com'});

// PUT request
await put('/users/123', data: {'name': 'Updated'});

// DELETE request
await delete('/users/123');

// PATCH request
await patch('/users/123', data: {'status': 'active'});

// Upload file
await uploadFile('/upload', data: {...}, files: [...]);

// Download file
await downloadFile(url, savePath);
```

### Exception Types

```dart
try {
  await get('/data');
} on SessionExpiredException {
  // Session expired - auto-logout triggered
} on NoInternetException {
  // No internet connection
} on TimeoutException {
  // Request timeout
} on ServerException catch (e) {
  // Server error (500+)
  print('Status: ${e.statusCode}');
} on NetworkException catch (e) {
  // Generic network error
  print('Message: ${e.message}');
  print('Status: ${e.statusCode}');
  print('Data: ${e.data}');
}
```

## Configuration

### NetworkConfig

```dart
NetworkConfig(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  headers: {'Custom-Header': 'value'},
  enableLogging: kDebugMode,
  maxRetries: 3,
  ignoreCookieExpires: false,
)
```

### NetworkCallbacks

```dart
NetworkCallbacks(
  getAuthToken: () async {
    // Return token from storage
    return await storage.getToken();
  },

  onSessionExpired: () async {
    // Handle logout, navigation, etc.
    await storage.clear();
    navigator.pushToLogin();
  },

  onSessionCookie: (sessionId) async {
    // Save session ID
    await storage.saveSession(sessionId);
  },

  isSessionExpired: (errorData) {
    // Custom session expiration check
    return errorData['code'] == 'SESSION_EXPIRED';
  },
)
```

## Documentation

For complete documentation, see:

- **[NETWORK_SERVICE_GUIDE.md](./NETWORK_SERVICE_GUIDE.md)** - Comprehensive usage guide
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history

## Example Integration

See the main HRMS app for a complete example:

- **`/lib/core/services/network_init.dart`** - App-specific initialization
- **`/lib/core/controllers/check_point_controller.dart`** - Usage in app startup

## Best Practices

1. **Always use `debugPrint()`** - Never use `print()` for logging
2. **Handle all exception types** - Use specific catches for better UX
3. **Use request IDs for cancellation** - Cancel long-running requests when needed
4. **Show progress for large files** - Better user experience
5. **Type-safe responses** - Use generics for cleaner code

## Contributing

When adding to the core package:

1. Keep it generic - No app-specific dependencies
2. Use callbacks for app integration
3. Add tests for new features
4. Update documentation
5. Follow existing patterns

## License

Proprietary - Internal use for HRMS and related projects
