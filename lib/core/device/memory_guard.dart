import 'device_info.dart';

class MemoryTooLowException implements Exception {
  const MemoryTooLowException(this.availableBytes, this.requiredBytes);

  final int availableBytes;
  final int requiredBytes;

  @override
  String toString() =>
      'Zu wenig freier Arbeitsspeicher (${DeviceSnapshot.gb(availableBytes)} frei, '
      '${DeviceSnapshot.gb(requiredBytes)} nötig). Bitte andere Apps schließen und erneut versuchen.';
}

/// Prüft vor dem Laden des Modells, ob genug Speicher frei ist, damit die App
/// nicht vom System beendet wird. Ziel laut Plan: App-Spitze ≤ ~2 GB.
class MemoryGuard {
  const MemoryGuard({this.requiredFreeBytes = 2200 * 1024 * 1024});

  /// Android meldet MemAvailable optimistisch (lmkd beendet Apps früher),
  /// daher etwas Puffer über dem erwarteten Bedarf von ~1,5–2 GB.
  final int requiredFreeBytes;

  Future<DeviceSnapshot> check() async {
    final s = await DeviceInfo.snapshot();
    final avail = s.availRamBytes;
    if (avail != null && avail < requiredFreeBytes) {
      throw MemoryTooLowException(avail, requiredFreeBytes);
    }
    return s;
  }
}
