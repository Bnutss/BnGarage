import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../cars/presentation/providers/cars_provider.dart';
import '../../../service_records/presentation/providers/service_records_provider.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/restore_service.dart';

enum GarageSyncStatus { idle, backingUp, restoring, success, error }

class GarageSyncState {
  final GarageSyncStatus status;
  final String? errorMessage;

  const GarageSyncState({
    this.status = GarageSyncStatus.idle,
    this.errorMessage,
  });
}

class GarageSyncNotifier extends Notifier<GarageSyncState> {
  @override
  GarageSyncState build() => const GarageSyncState();

  Future<void> backup() async {
    state = const GarageSyncState(status: GarageSyncStatus.backingUp);
    try {
      final service = BackupService(ref.read(dioProvider));
      await service.run();
      state = const GarageSyncState(status: GarageSyncStatus.success);
    } catch (e) {
      state = GarageSyncState(
        status: GarageSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Used right after sign-in to decide whether to offer a restore prompt.
  Future<bool> hasCloudBackup() async {
    try {
      return await RestoreService(ref.read(dioProvider)).hasCloudData();
    } catch (_) {
      return false;
    }
  }

  Future<void> restore() async {
    state = const GarageSyncState(status: GarageSyncStatus.restoring);
    try {
      final service = RestoreService(ref.read(dioProvider));
      await service.run();
      ref.invalidate(carsProvider);
      ref.invalidate(serviceRecordsProvider);
      state = const GarageSyncState(status: GarageSyncStatus.success);
    } catch (e) {
      state = GarageSyncState(
        status: GarageSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const GarageSyncState();
  }
}

final garageSyncProvider =
    NotifierProvider<GarageSyncNotifier, GarageSyncState>(
      GarageSyncNotifier.new,
    );
