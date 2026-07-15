import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cars/presentation/providers/cars_provider.dart';
import 'auth_token_provider.dart';
import 'garage_sync_provider.dart';

/// Silently triggers a debounced cloud backup whenever [carsProvider] is
/// invalidated — which every existing car/service-record add, edit, and
/// delete flow already does — so no per-screen wiring is needed. Only runs
/// while signed in; no UI feedback (matches the "just works, no buttons"
/// intent — a manual "Backup now" is still available in Settings).
///
/// Wire up once near the app root via `ref.watch(autoBackupProvider)` so the
/// listener stays alive for the whole session.
class AutoBackupCoordinator extends Notifier<void> {
  Timer? _debounce;

  @override
  void build() {
    ref.listen(carsProvider, (previous, next) {
      // Extra backup calls on app-launch's first load are cheap and
      // idempotent, so there's no need to special-case it away here.
      if (next.hasValue) _scheduleBackup();
    });
    ref.onDispose(() => _debounce?.cancel());
  }

  void _scheduleBackup() {
    if (ref.read(authTokenProvider).value == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      ref.read(garageSyncProvider.notifier).backup();
    });
  }
}

final autoBackupProvider = NotifierProvider<AutoBackupCoordinator, void>(
  AutoBackupCoordinator.new,
);
