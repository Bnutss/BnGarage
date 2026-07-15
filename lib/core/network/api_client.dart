import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_token_provider.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final tokens = ref.read(authTokenProvider).value;
        if (tokens != null) {
          options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final tokens = ref.read(authTokenProvider).value;
        final isAuthEndpoint =
            error.requestOptions.path.contains('/api/auth/telegram/') ||
            error.requestOptions.path.contains('/api/auth/token/refresh/');

        if (error.response?.statusCode == 401 &&
            tokens != null &&
            !isAuthEndpoint) {
          try {
            final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
            final response = await refreshDio.post(
              '/api/auth/token/refresh/',
              data: {'refresh': tokens.refreshToken},
            );
            final newTokens = tokens.copyWith(
              accessToken: response.data['access'] as String,
            );
            await ref.read(authTokenProvider.notifier).setTokens(newTokens);

            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] =
                'Bearer ${newTokens.accessToken}';
            final retryResponse = await dio.fetch(retryOptions);
            handler.resolve(retryResponse);
            return;
          } catch (_) {
            await ref.read(authTokenProvider.notifier).clear();
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
