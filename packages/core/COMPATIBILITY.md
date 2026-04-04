# Core Package - Compatibility Guide

This document explains how the core package DioService relates to your existing app's DioService.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Your HRMS App                           │
├─────────────────────────────────────────────────────────────┤
│  lib/core/services/dio_service.dart                         │
│  - Production-ready DioService                              │
│  - Odoo session management                                  │
│  - Auto-logout on 401/session expiration                    │
│  - Token auto-injection from SharedPreferences              │
│  - Custom printer/errorPrint logging                        │
│  - Session validation logic                                 │
│  - Profile controller integration                           │
│  - Navigation integration                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Can use or extend
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Core Package (Generic)                     │
├─────────────────────────────────────────────────────────────┤
│  packages/core/lib/src/services/dio_service.dart            │
│  - Generic, reusable base implementation                    │
│  - Support for both CookieJar and PersistCookieJar         │
│  - Configurable logging (uses debugPrint)                   │
│  - Custom interceptor support                               │
│  - makeRequest helper function                              │
│  - HTTPMethod enum                                          │
│  - No app-specific logic                                    │
└─────────────────────────────────────────────────────────────┘
```

## Key Differences

### Your App's DioService (Production)
**File**: `/lib/core/services/dio_service.dart`

✅ **Use this for your HRMS app** - It's production-ready with:
- Odoo-specific session management
- Auto-logout on session expiration
- Integration with your app's navigation and storage
- Custom logging with `printer()`/`errorPrint()`

```dart
// Your existing initialization
await DioService.instance.init();

// Your existing usage
final response = await makeRequest(
  path: '/employee/profile',
  method: HTTPMethod.get,
);
```

### Core Package DioService (Generic)
**File**: `packages/core/lib/src/services/dio_service.dart`

✅ **Use this for**:
- New projects that need a base HTTP service
- Microservices or separate packages
- When you don't need Odoo-specific logic
- Projects that want a clean, generic HTTP client

```dart
// Core package initialization
await DioService.instance.initialize(
  baseUrl: 'https://api.example.com',
  enableLogging: true,
);

// Core package usage
final response = await makeRequest(
  path: '/users',
  method: HTTPMethod.get,
);
```

## Compatibility Status

| Feature | Your App | Core Package | Compatible? |
|---------|----------|--------------|-------------|
| **HTTPMethod enum** | ✅ | ✅ | ✅ Yes - Same values |
| **makeRequest()** | ✅ | ✅ | ✅ Yes - Similar signature |
| **Singleton pattern** | ✅ | ✅ | ✅ Yes - Same pattern |
| **Cookie management** | ✅ PersistCookieJar | ✅ Configurable | ✅ Compatible |
| **Logging** | printer/errorPrint | debugPrint | ⚠️ Different but both work |
| **Session management** | ✅ Odoo-specific | ❌ None | ⚠️ App adds on top |
| **Auto-logout** | ✅ Yes | ❌ None | ⚠️ App adds on top |

## Recommendation: Keep Both

### Keep Your App's DioService
**Continue using** `lib/core/services/dio_service.dart` for your HRMS app because it has:
1. Production-tested Odoo session handling
2. Integrated auto-logout flow
3. Your custom logging format
4. Profile controller integration

### Use Core Package For
1. **New shared packages** that other apps might use
2. **Microservices** that don't need Odoo logic
3. **Learning/reference** for clean architecture patterns
4. **Future projects** that need a generic HTTP client

## Migration Path (Optional)

If you want to eventually consolidate, here's how:

### Option 1: Extend Core Package (Future)
```dart
// In your app
class HRMDioService extends DioService {
  // Add your Odoo-specific logic here
  // Keep session management
  // Keep auto-logout
}
```

### Option 2: Keep Separate (Recommended)
Continue using your app's DioService as-is. It's working perfectly for your needs.

## Summary

✅ **Both DioServices are compatible** in terms of API structure
✅ **Your app's DioService is production-ready** - keep using it
✅ **Core package DioService is generic** - use for new/shared projects
✅ **No migration needed** - they serve different purposes

The core package provides a **clean, generic foundation** that can be used across different projects, while your app's DioService is **specifically optimized for your HRMS + Odoo architecture**.
