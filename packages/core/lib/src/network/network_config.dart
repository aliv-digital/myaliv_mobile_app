/// Network service configuration and callbacks
///
/// This file contains configuration classes for the NetworkService.
/// Responsible for: Service configuration and app-specific callbacks.
library;

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
