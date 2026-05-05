/// Network service configuration and callbacks
///
/// This file contains configuration classes for the NetworkService.
/// Responsible for: Service configuration and app-specific callbacks.
library;

/// Body formatting mode for request/response logging.
///
/// - [pretty]: indented JSON (most vertical space)
/// - [compact]: single-line JSON (saves vertical space, recommended)
/// - [summary]: arrays collapsed to length+sample, maps shallow
/// - [off]: do not log body at all
enum NetworkLogBodyMode { pretty, compact, summary, off }

/// Logging configuration for [NetworkLoggingInterceptor].
class NetworkLogConfig {
  /// Format mode for request/response bodies.
  final NetworkLogBodyMode bodyMode;

  /// Print request headers.
  final bool logRequestHeaders;

  /// Print request body.
  final bool logRequestBody;

  /// Print response headers.
  final bool logResponseHeaders;

  /// Print response body.
  final bool logResponseBody;

  /// Maximum characters to print for any body. Excess is truncated with a marker.
  final int maxBodyChars;

  /// When a JSON array exceeds this length, only the first N items are logged.
  /// Applies to compact and pretty modes; summary mode always collapses arrays.
  final int maxArrayItems;

  /// Include the Dart stack trace on errors.
  final bool logErrorStack;

  /// On error, also log the request body that triggered it.
  final bool logErrorRequestBody;

  const NetworkLogConfig({
    this.bodyMode = NetworkLogBodyMode.compact,
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.maxBodyChars = 20000,
    this.maxArrayItems = 50,
    this.logErrorStack = false,
    this.logErrorRequestBody = true,
  });
}

/// Network service configuration
class NetworkConfig {
  /// Base URL for all API requests
  final String baseUrl;

  /// Connection timeout duration
  final Duration connectTimeout;

  /// Response receive timeout duration
  final Duration receiveTimeout;

  /// Additional headers to be sent with every request
  final Map<String, dynamic>? headers;

  /// Enable request/response logging (only works in debug mode)
  final bool enableLogging;

  /// Fine-grained logging behavior (body format, truncation, etc.)
  final NetworkLogConfig logConfig;

  /// Maximum number of retry attempts for failed requests
  final int maxRetries;

  /// Ignore cookie expiration dates (useful for development)
  final bool ignoreCookieExpires;

  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.headers,
    this.enableLogging = true,
    this.logConfig = const NetworkLogConfig(),
    this.maxRetries = 3,
    this.ignoreCookieExpires = false,
  });
}

/// Callbacks for app-specific behavior
///
/// These callbacks allow the NetworkService to integrate with app-specific
/// logic like authentication, navigation, and session management.
class NetworkCallbacks {
  /// Get authentication token from storage
  ///
  /// Called before each request to inject the auth token in headers.
  /// Return null if no token is available.
  final Future<String?> Function()? getAuthToken;

  /// Handle session expiration (logout, navigation, etc.)
  ///
  /// Called when a 401 response or session expired error is detected.
  /// Use this to clear app state and navigate to login screen.
  final Future<void> Function()? onSessionExpired;

  /// Handle successful session cookie
  ///
  /// Called when a valid session_id cookie is found.
  /// Use this to store the session ID in app state.
  final Future<void> Function(String sessionId)? onSessionCookie;

  /// Check if error response indicates session expiration
  ///
  /// Provide custom logic to detect session expiration from error responses.
  /// Return true if the error indicates an expired session.
  final bool Function(dynamic errorData)? isSessionExpired;

  const NetworkCallbacks({
    this.getAuthToken,
    this.onSessionExpired,
    this.onSessionCookie,
    this.isSessionExpired,
  });
}
