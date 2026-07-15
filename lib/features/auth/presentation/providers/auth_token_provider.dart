import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/auth_tokens.dart';

const _kAccessKey = 'auth_access_token';
const _kRefreshKey = 'auth_refresh_token';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class AuthTokenNotifier extends AsyncNotifier<AuthTokens?> {
  @override
  Future<AuthTokens?> build() async {
    final storage = ref.watch(secureStorageProvider);
    final access = await storage.read(key: _kAccessKey);
    final refresh = await storage.read(key: _kRefreshKey);
    if (access == null || refresh == null) return null;
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> setTokens(AuthTokens tokens) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _kAccessKey, value: tokens.accessToken);
    await storage.write(key: _kRefreshKey, value: tokens.refreshToken);
    state = AsyncData(tokens);
  }

  Future<void> clear() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: _kAccessKey);
    await storage.delete(key: _kRefreshKey);
    state = const AsyncData(null);
  }
}

final authTokenProvider = AsyncNotifierProvider<AuthTokenNotifier, AuthTokens?>(
  AuthTokenNotifier.new,
);
