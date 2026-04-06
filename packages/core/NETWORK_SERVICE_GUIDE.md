oj# NetworkService Usage Guide

## Overview

`NetworkService` is an enhanced HTTP client built on top of Dio with the following improvements over the old `DioService`:

### Key Improvements

✅ **Uses `debugPrint()` throughout** - No `print()` statements
✅ **Better error handling** - Custom exception types
✅ **Request cancellation** - Cancel individual or all requests
✅ **Progress tracking** - Upload/download progress callbacks
✅ **Type-safe requests** - Generic response types
✅ **Auto-retry logic** - Configurable retry attempts
✅ **Cleaner architecture** - Separation of concerns
✅ **Better logging** - Structured, formatted logs
✅ **Session management** - Automatic token injection & session validation

## Initialization

### Basic Initialization

```dart
// In your main.dart or initialization code
await NetworkService.instance.init();
```

### Custom Configuration

```dart
await NetworkService.instance.init(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    enableLogging: kDebugMode,
    maxRetries: 3,
    headers: {
      'Custom-Header': 'value',
    },
  ),
);
```

## Basic Usage

### Using Helper Functions (Recommended)

```dart
import 'package:hrm/core/network/network_helpers.dart';

// GET request
final response = await get('/users');

// POST request
final response = await post('/login', data: {
  'email': 'user@example.com',
  'password': 'password123',
});

// PUT request
final response = await put('/users/123', data: {
  'name': 'Updated Name',
});

// DELETE request
final response = await delete('/users/123');

// PATCH request
final response = await patch('/users/123', data: {
  'status': 'active',
});
```

### Using NetworkService Directly

```dart
import 'package:hrm/core/network/network_service.dart';

final response = await NetworkService.instance.request(
  '/users',
  method: HttpMethod.get,
);
```

## Advanced Features

### 1. Type-Safe Requests

```dart
// Generic response type
final response = await get<Map<String, dynamic>>('/user/profile');
final data = response.data; // Typed as Map<String, dynamic>
```

### 2. Query Parameters

```dart
final response = await get(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 20,
    'status': 'active',
  },
);
```

### 3. Custom Headers

```dart
final response = await post(
  '/data',
  data: {'key': 'value'},
  options: Options(
    headers: {'X-Custom-Header': 'value'},
  ),
);
```

### 4. File Upload with Progress

```dart
final file = await MultipartFile.fromFile(
  '/path/to/file.jpg',
  filename: 'profile.jpg',
);

final response = await uploadFile(
  '/upload',
  data: {
    'title': 'Profile Picture',
    'description': 'My avatar',
  },
  files: [
    MapEntry('file', file),
  ],
  onProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    debugPrint('Upload progress: $progress%');
  },
);
```

### 5. File Download with Progress

```dart
final savePath = '/path/to/save/file.pdf';

await downloadFile(
  '/files/document.pdf',
  savePath,
  onProgress: (received, total) {
    if (total != -1) {
      final progress = (received / total * 100).toStringAsFixed(0);
      debugPrint('Download progress: $progress%');
    }
  },
);
```

### 6. Request Cancellation

```dart
// Using request ID for cancellation
final response = await get(
  '/long-running-request',
  requestId: 'fetch-data',
);

// Cancel by ID
NetworkService.instance.cancelRequest('fetch-data');

// Cancel all requests
NetworkService.instance.cancelAllRequests();
```

### 7. Manual Cancel Token

```dart
final cancelToken = CancelToken();

// Start request
final future = get(
  '/data',
  cancelToken: cancelToken,
);

// Cancel when needed
cancelToken.cancel('User cancelled');
```

## Error Handling

### Exception Types

```dart
try {
  final response = await get('/users');
} on SessionExpiredException {
  // Session expired - user will be logged out automatically
  debugPrint('Session expired');
} on NoInternetException {
  // No internet connection
  showSnackBar('No internet connection');
} on TimeoutException {
  // Request timeout
  showSnackBar('Request timeout');
} on ServerException catch (e) {
  // Server error (500+)
  showSnackBar('Server error: ${e.message}');
} on NetworkException catch (e) {
  // Generic network error
  showSnackBar('Error: ${e.message}');
} catch (e) {
  // Unexpected error
  debugPrint('Unexpected error: $e');
}
```

### Error Response Data

```dart
try {
  final response = await post('/api/endpoint', data: data);
} on NetworkException catch (e) {
  debugPrint('Status: ${e.statusCode}');
  debugPrint('Message: ${e.message}');
  debugPrint('Data: ${e.data}');
}
```

## Session Management

### Check Session Validity

```dart
final hasSession = await NetworkService.instance.hasValidSession();
if (hasSession) {
  // User has valid session
} else {
  // Redirect to login
}
```

### Clear Session

```dart
await NetworkService.instance.clearCookies();
```

## Migration from Old DioService

### Old Code

```dart
import 'package:hrm/core/network/dio_service.dart';

final response = await makeRequest(
  path: '/users',
  method: HTTPMethod.get,
);
```

### New Code

```dart
import 'package:hrm/core/network/network_helpers.dart';

final response = await get('/users');
```

### Key Changes

| Old | New |
|-----|-----|
| `DioService.instance.init()` | `NetworkService.instance.init()` |
| `makeRequest(path: '/users', method: HTTPMethod.get)` | `get('/users')` |
| `HTTPMethod` enum | `HttpMethod` enum |
| `print()` statements | `debugPrint()` statements |
| Manual error parsing | Custom exception types |
| No request cancellation | Built-in cancellation |
| No progress tracking | Upload/download progress |

## Best Practices

### 1. Always Handle Errors

```dart
try {
  final response = await get('/data');
  // Handle success
} on NetworkException catch (e) {
  // Handle error
  showSnackBar(e.message);
}
```

### 2. Use Request IDs for Cancellable Requests

```dart
// Start request with ID
final response = await get('/search', requestId: 'search-query');

// Cancel if user types new query
NetworkService.instance.cancelRequest('search-query');
```

### 3. Show Progress for Large Files

```dart
await uploadFile(
  '/upload',
  data: data,
  files: files,
  onProgress: (sent, total) {
    // Update UI with progress
    setState(() {
      uploadProgress = sent / total;
    });
  },
);
```

### 4. Use Type-Safe Responses

```dart
// Instead of dynamic
final response = await get('/user');
final data = response.data as Map<String, dynamic>;

// Use generics
final response = await get<Map<String, dynamic>>('/user');
final data = response.data; // Already typed
```

## Debugging

### Enable Verbose Logging

Logging is automatically enabled in debug mode. All requests, responses, and errors are logged with:

- 🚀 Request details
- 📦 Headers
- 📤 Request data
- ✅ Response status
- 📥 Response data
- ❌ Error details

### Disable Logging

```dart
await NetworkService.instance.init(
  config: NetworkConfig(
    baseUrl: ENV().baseUrl,
    enableLogging: false, // Disable logs
  ),
);
```

## Testing

### Mock Responses

```dart
// For testing, you can access the Dio instance
final dio = NetworkService.instance.dio;

// Add test interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // Return mock response
    return handler.resolve(Response(
      requestOptions: options,
      data: {'mock': 'data'},
    ));
  },
));
```

### Reset Instance

```dart
// Useful for testing
NetworkService.reset();
```

## Performance Tips

1. **Reuse NetworkService instance** - It's a singleton
2. **Cancel unnecessary requests** - Save bandwidth
3. **Use appropriate timeouts** - Don't wait forever
4. **Enable compression** - Add Accept-Encoding header
5. **Cache responses** - Use Dio's cache interceptor for static data

## Troubleshooting

### Issue: "NetworkService not initialized"

**Solution**: Call `await NetworkService.instance.init()` before making requests

### Issue: Session keeps expiring

**Solution**: Check cookie expiration settings and ensure server is sending proper session cookies

### Issue: Timeout on slow connections

**Solution**: Increase timeout in configuration:

```dart
NetworkConfig(
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
)
```

### Issue: Upload/download not showing progress

**Solution**: Ensure you're passing the `onProgress` callback

## Support

For issues or questions, refer to:
- `network_service.dart` source code
- `network_helpers.dart` helper functions
- Dio documentation: https://pub.dev/packages/dio
