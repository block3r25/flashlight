import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightUnavailableException implements Exception {
  const FlashlightUnavailableException();
}

class FlashlightPermissionException implements Exception {
  const FlashlightPermissionException(this.permanentlyDenied);

  final bool permanentlyDenied;
}

class FlashlightService {
  Future<void> _pendingOperation = Future<void>.value();

  Future<bool> isAvailable() => _enqueue(TorchLight.isTorchAvailable);

  Future<void> turnOn() => _enqueue(() async {
    if (!await TorchLight.isTorchAvailable()) {
      throw const FlashlightUnavailableException();
    }

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      throw FlashlightPermissionException(permission.isPermanentlyDenied);
    }

    await TorchLight.enableTorch();
  });

  Future<void> turnOff() => _enqueue(TorchLight.disableTorch);

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pendingOperation.then((_) => operation());
    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }
}
