import 'dart:convert';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://reru.odukar.com';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String? accessToken;

  const ApiClient({this.accessToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.get(uri, headers: _headers);
    return _handle(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['ok'] == true) return json['data'];
    throw ApiException(
      response.statusCode,
      json['error'] as String? ?? 'Unknown error',
    );
  }
}
