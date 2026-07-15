import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_tokens.dart';
import '../models/telegram_profile.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Trades the one-time code from the Telegram Login Widget callback
  /// redirect for a real JWT pair.
  Future<AuthTokens> exchangeCode(String code) async {
    final response = await _dio.post(
      '/api/auth/telegram/exchange/',
      data: {'code': code},
    );
    final data = response.data as Map<String, dynamic>;
    return AuthTokens(
      accessToken: data['access'] as String,
      refreshToken: data['refresh'] as String,
    );
  }

  Future<TelegramProfile> me() async {
    final response = await _dio.get('/api/auth/me/');
    return TelegramProfile.fromJson(response.data as Map<String, dynamic>);
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.read(dioProvider));
});
