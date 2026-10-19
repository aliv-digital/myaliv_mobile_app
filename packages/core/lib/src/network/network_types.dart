/// Network type definitions
///
/// This file contains type definitions and enums for network operations.
/// Responsible for: Type safety and method definitions.
library;

/// HTTP request methods
///
/// Defines the standard HTTP methods supported by the NetworkService.
enum HttpMethod {
  /// GET - Retrieve data from server
  get,

  /// POST - Send data to server to create/update
  post,

  /// PUT - Update existing data on server
  put,

  /// DELETE - Remove data from server
  delete,

  /// PATCH - Partially update data on server
  patch,
}
