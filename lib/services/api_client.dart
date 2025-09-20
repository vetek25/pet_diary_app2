import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, details: $details)';
}

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  String? _token;
  final http.Client _http = http.Client();

  void updateToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = _composeUri(path);
    try {
      final response = await _http.get(
        uri,
        headers: _headers(),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (error) {
      throw ApiException(
        'Network error: ${error.message}',
        details: {'uri': uri.toString()},
      );
    } catch (error) {
      throw ApiException(
        'Network error: $error',
        details: {'uri': uri.toString()},
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _composeUri(path);
    final payload = body ?? const <String, dynamic>{};
    final useFormEncoding = kIsWeb && _canFormEncode(payload);
    try {
      final response = await _http.post(
        uri,
        headers: _headers(
          contentType: useFormEncoding
              ? 'application/x-www-form-urlencoded'
              : 'application/json',
        ),
        body: useFormEncoding
            ? _stringify(payload)
            : jsonEncode(payload),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (error) {
      throw ApiException(
        'Network error: ${error.message}',
        details: {'uri': uri.toString()},
      );
    } catch (error) {
      throw ApiException(
        'Network error: $error',
        details: {'uri': uri.toString()},
      );
    }
  }

  Uri _composeUri(String path) {
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, String> _headers({String? contentType}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    final token = _token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (response.body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return <String, dynamic>{};
      }
      throw ApiException('Request failed', statusCode: statusCode);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Invalid response format', statusCode: statusCode);
    }

    Map<String, dynamic> payload;
    if (decoded is Map<String, dynamic>) {
      payload = decoded;
    } else if (decoded is Map) {
      payload = Map<String, dynamic>.from(decoded);
    } else {
      throw ApiException('Invalid response format', statusCode: statusCode);
    }

    if (statusCode >= 200 && statusCode < 300) {
      return payload;
    }

    final message = payload['message']?.toString() ??
        payload['error']?.toString() ??
        'Request failed';
    throw ApiException(
      message,
      statusCode: statusCode,
      details: payload,
    );
  }

  bool _canFormEncode(Map<String, dynamic> body) {
    return body.values.every((value) {
      return value == null ||
          value is String ||
          value is num ||
          value is bool;
    });
  }

  Map<String, String> _stringify(Map<String, dynamic> body) {
    final encoded = <String, String>{};
    for (final entry in body.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      encoded[entry.key] = value.toString();
    }
    return encoded;
  }
}
