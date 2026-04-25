import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

const _keyAccessToken  = 'access_token';
const _keyRefreshToken = 'refresh_token';
const _keyExpiresAt    = 'expires_at';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final int expiresAt;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt - 60;
}

class AuthService {
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<AuthSession> login(String email, String password) async {
    final client = ApiClient();
    final data = await client.post('/api/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final authSession = AuthSession(
      accessToken: session['access_token'] as String,
      refreshToken: session['refresh_token'] as String,
      expiresAt: (session['expires_at'] as num).toInt(),
    );
    await _persist(authSession);
    return authSession;
  }

  static Future<AuthSession> refresh(String refreshToken) async {
    final client = ApiClient();
    final data = await client.post('/api/auth/refresh', {
      'refresh_token': refreshToken,
    }) as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final authSession = AuthSession(
      accessToken: session['access_token'] as String,
      refreshToken: session['refresh_token'] as String,
      expiresAt: (session['expires_at'] as num).toInt(),
    );
    await _persist(authSession);
    return authSession;
  }

  static Future<void> logout(String accessToken) async {
    try {
      final client = ApiClient(accessToken: accessToken);
      await client.post('/api/auth/logout', {});
    } finally {
      await _storage.deleteAll();
    }
  }

  static Future<AuthSession?> getStoredSession() async {
    final accessToken  = await _storage.read(key: _keyAccessToken);
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (accessToken == null || refreshToken == null || expiresAtStr == null) {
      return null;
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: int.parse(expiresAtStr),
    );
  }

  static Future<String?> getValidAccessToken() async {
    var session = await getStoredSession();
    if (session == null) return null;
    if (session.isExpired) {
      try {
        session = await refresh(session.refreshToken);
      } on ApiException {
        await _storage.deleteAll();
        return null;
      }
    }
    return session.accessToken;
  }

  static Future<void> _persist(AuthSession session) async {
    await _storage.write(key: _keyAccessToken,  value: session.accessToken);
    await _storage.write(key: _keyRefreshToken, value: session.refreshToken);
    await _storage.write(key: _keyExpiresAt,    value: '${session.expiresAt}');
  }
}
