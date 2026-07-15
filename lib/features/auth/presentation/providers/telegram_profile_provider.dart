import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/telegram_profile.dart';
import '../../data/services/auth_api_service.dart';
import 'auth_token_provider.dart';

final telegramProfileProvider = FutureProvider<TelegramProfile?>((ref) async {
  final tokens = await ref.watch(authTokenProvider.future);
  if (tokens == null) return null;
  try {
    return await ref.read(authApiServiceProvider).me();
  } catch (_) {
    // The account this token belongs to may no longer exist (e.g. deleted
    // via the Django admin) — drop the stale token so the UI falls back to
    // the signed-out state instead of getting stuck believing it's signed
    // in with a token nothing can use.
    await ref.read(authTokenProvider.notifier).clear();
    return null;
  }
});
