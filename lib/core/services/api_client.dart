import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// The neFaRec API. Defaults to the API running on this Mac, which the iOS
/// simulator reaches as 127.0.0.1. Override with
/// `--dart-define=NEFAREC_API=http://<host>:4100`.
const apiBaseUrl = String.fromEnvironment('NEFAREC_API', defaultValue: 'http://127.0.0.1:4100');

class ApiException implements Exception {
  const ApiException(this.message, {this.status, this.code});
  final String message;
  final int? status;
  final String? code;

  bool get offline => status == null;

  @override
  String toString() => message;
}

/// Tokens live in the Keychain / Keystore, never in the app database.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const _access = 'nefarec.access';
  static const _refresh = 'nefarec.refresh';

  Future<String?> access() => _storage.read(key: _access);
  Future<String?> refresh() => _storage.read(key: _refresh);

  Future<void> save(String access, String refresh) async {
    await _storage.write(key: _access, value: access);
    await _storage.write(key: _refresh, value: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

class ApiClient {
  ApiClient({required this.tokens, http.Client? client, this.baseUrl = apiBaseUrl})
    : _http = client ?? http.Client();

  final TokenStore tokens;
  final String baseUrl;
  final http.Client _http;
  Future<bool>? _refreshing;

  Future<Map<String, dynamic>?> get(String path) => _send('GET', path);
  Future<Map<String, dynamic>?> post(String path, [Object? body]) =>
      _send('POST', path, body: body);
  Future<Map<String, dynamic>?> patch(String path, Object body) => _send('PATCH', path, body: body);
  Future<Map<String, dynamic>?> delete(String path) => _send('DELETE', path);

  /// Calls without an access token (sign-in, sign-up).
  Future<Map<String, dynamic>> anonymous(String path, Object body) async =>
      (await _send('POST', path, body: body, auth: false))!;

  Future<Map<String, dynamic>?> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
    bool retried = false,
  }) async {
    final headers = {'content-type': 'application/json', 'accept': 'application/json'};
    if (auth) {
      final token = await tokens.access();
      if (token == null) {
        throw const ApiException('Sign in first.', status: 401, code: 'unauthorized');
      }
      headers['authorization'] = 'Bearer $token';
    }
    final http.Response res;
    try {
      final req = http.Request(method, Uri.parse('$baseUrl$path'))..headers.addAll(headers);
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(
        await _http.send(req).timeout(const Duration(seconds: 20)),
      );
    } on TimeoutException {
      throw const ApiException('The server took too long to answer. Check your connection.');
    } catch (_) {
      throw const ApiException(
        'Can’t reach the neFaRec server. Your workouts are still saved on this phone.',
      );
    }

    if (res.statusCode == 401 && auth && !retried && await _refresh()) {
      return _send(method, path, body: body, auth: auth, retried: true);
    }
    final json = res.body.isEmpty ? null : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(
        json?['message'] as String? ?? 'Request failed (${res.statusCode}).',
        status: res.statusCode,
        code: json?['error'] as String?,
      );
    }
    return json;
  }

  /// One refresh at a time, even if several calls hit an expired token.
  Future<bool> _refresh() => _refreshing ??= () async {
    try {
      final refresh = await tokens.refresh();
      if (refresh == null) return false;
      final json = await _send(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refresh},
        auth: false,
      );
      await tokens.save(json!['accessToken'] as String, json['refreshToken'] as String);
      return true;
    } on ApiException {
      return false;
    } finally {
      _refreshing = null;
    }
  }();
}
