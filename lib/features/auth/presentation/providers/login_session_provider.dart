import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../data/services/auth_api_service.dart';
import '../screens/telegram_login_webview_screen.dart';
import 'auth_token_provider.dart';

enum LoginSessionStatus { idle, launching, error }

class LoginSessionState {
  final LoginSessionStatus status;
  final String? errorMessage;

  const LoginSessionState({
    this.status = LoginSessionStatus.idle,
    this.errorMessage,
  });
}

class LoginSessionNotifier extends Notifier<LoginSessionState> {
  @override
  LoginSessionState build() => const LoginSessionState();

  Future<void> startTelegramLogin(BuildContext context) async {
    state = const LoginSessionState(status: LoginSessionStatus.launching);

    try {
      final code = await Navigator.of(context).push<String?>(
        MaterialPageRoute(
          builder: (_) => TelegramLoginWebViewScreen(
            initialUrl: '${AppConstants.apiBaseUrl}/api/auth/telegram/widget/',
            widgetCallbackUrl: '/api/auth/telegram/widget-callback/',
            callbackScheme: 'bngarage',
            dio: ref.read(dioProvider),
          ),
        ),
      );

      if (code == null) {
        state = const LoginSessionState(status: LoginSessionStatus.idle);
        return;
      }

      final tokens = await ref.read(authApiServiceProvider).exchangeCode(code);
      await ref.read(authTokenProvider.notifier).setTokens(tokens);
      state = const LoginSessionState(status: LoginSessionStatus.idle);
    } catch (e) {
      state = LoginSessionState(
        status: LoginSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const LoginSessionState();
  }
}

final loginSessionProvider =
    NotifierProvider<LoginSessionNotifier, LoginSessionState>(
      LoginSessionNotifier.new,
    );
