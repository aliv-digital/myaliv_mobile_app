import 'dart:convert';

class ApiErrorMessageResolver {
  const ApiErrorMessageResolver._();

  /// Returns a user-friendly message for API failures.
  ///
  /// Priority:
  /// 1) non-empty [backendMessage] / parsed message from [responseBody]
  /// 2) status-code based fallback
  static String resolve({
    required int statusCode,
    String? responseBody,
    String? backendMessage,
    bool preferBackendMessage = true,
  }) {
    final String? parsedMessage = _firstNonEmpty(
      <String?>[
        _normalize(backendMessage),
        _extractBackendMessage(responseBody),
      ],
    );

    if (preferBackendMessage && parsedMessage != null) {
      return parsedMessage;
    }

    final String fallback = fallbackForStatusCode(statusCode);

    if (!preferBackendMessage && parsedMessage != null) {
      return parsedMessage;
    }
    return fallback;
  }

  /// Status-code only fallback message map.
  static String fallbackForStatusCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return 'Request completed successfully.';
    }

    switch (statusCode) {
      case 0:
        return 'No internet connection. Please check your network and try again.';
      case 100:
      case 101:
      case 102:
      case 103:
        return 'Your request is still being processed. Please try again.';
      case 300:
      case 301:
      case 302:
      case 303:
      case 304:
      case 305:
      case 307:
      case 308:
        return 'Unexpected redirect from server. Please try again.';
      case 400:
        return 'Invalid request. Please review your input and try again.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 402:
        return 'Payment is required to continue.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
      case 405:
        return 'This action is not allowed.';
      case 406:
        return 'Requested response format is not supported.';
      case 407:
        return 'Proxy authentication is required.';
      case 408:
        return 'The request timed out. Please try again.';
      case 409:
        return 'Conflict detected. Please refresh and try again.';
      case 410:
        return 'This resource is no longer available.';
      case 411:
        return 'Request is missing required content length.';
      case 412:
        return 'Request precondition failed.';
      case 413:
        return 'Submitted data is too large.';
      case 414:
        return 'Request URL is too long.';
      case 415:
        return 'Unsupported media type.';
      case 416:
        return 'Requested range is not satisfiable.';
      case 417:
        return 'Request expectation failed.';
      case 418:
        return 'The server rejected this request.';
      case 421:
        return 'Request was sent to the wrong server.';
      case 422:
        return 'Unable to process request. Please check your input.';
      case 423:
        return 'Requested resource is locked.';
      case 424:
        return 'Request failed due to a dependent operation.';
      case 425:
        return 'Request was rejected because it was sent too early.';
      case 426:
        return 'Please update your app and try again.';
      case 428:
        return 'A required precondition is missing.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 431:
        return 'Request headers are too large.';
      case 451:
        return 'This content is unavailable for legal reasons.';
      case 500:
        return 'Server error. Please try again later.';
      case 501:
        return 'This feature is not available on the server.';
      case 502:
        return 'Bad gateway. Please try again in a moment.';
      case 503:
        return 'Service is temporarily unavailable. Please try again later.';
      case 504:
        return 'Server took too long to respond. Please try again.';
      case 505:
        return 'Server does not support this HTTP version.';
      case 506:
        return 'Server configuration error. Please try again later.';
      case 507:
        return 'Server is out of storage. Please try again later.';
      case 508:
        return 'Server loop detected. Please try again later.';
      case 510:
        return 'Further extensions are required by the server.';
      case 511:
        return 'Network authentication is required.';
      default:
        if (statusCode >= 100 && statusCode < 200) {
          return 'Your request is being processed. Please try again shortly.';
        }
        if (statusCode >= 300 && statusCode < 400) {
          return 'Unexpected redirect response. Please try again.';
        }
        if (statusCode >= 400 && statusCode < 500) {
          return 'Request failed. Please verify your input and try again.';
        }
        if (statusCode >= 500 && statusCode < 600) {
          return 'Server is unavailable right now. Please try again later.';
        }
        return 'Unexpected response from server ($statusCode).';
    }
  }

  static String? _extractBackendMessage(String? rawBody) {
    final String? raw = _normalize(rawBody);
    if (raw == null) return null;
    if (_looksLikeHtml(raw)) return null;

    final dynamic decoded = _tryDecode(raw);
    final String? extracted = _extractFromDynamic(decoded);
    if (extracted != null) return extracted;

    // Fallback for plain text responses.
    if (raw.length <= 280) return raw;
    return null;
  }

  static dynamic _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  static String? _extractFromDynamic(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return _normalize(value);
    }

    if (value is List) {
      for (final dynamic item in value) {
        final String? message = _extractFromDynamic(item);
        if (message != null) return message;
      }
      return null;
    }

    if (value is Map) {
      const List<String> preferredKeys = <String>[
        'message',
        'error',
        'detail',
        'description',
        'title',
        'reason',
        'error_description',
      ];

      for (final String key in preferredKeys) {
        final String? direct = _extractFromDynamic(value[key]);
        if (direct != null) return direct;
      }

      final String? fromErrors = _extractFromDynamic(value['errors']);
      if (fromErrors != null) return fromErrors;

      for (final dynamic nestedValue in value.values) {
        final String? nested = _extractFromDynamic(nestedValue);
        if (nested != null) return nested;
      }
    }

    return null;
  }

  static bool _looksLikeHtml(String text) {
    final String lower = text.toLowerCase();
    return lower.startsWith('<!doctype html') ||
        lower.startsWith('<html') ||
        lower.contains('<body');
  }

  static String? _normalize(String? text) {
    if (text == null) return null;
    final String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return null;
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      return cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final String? normalized = _normalize(value);
      if (normalized != null) return normalized;
    }
    return null;
  }
}
