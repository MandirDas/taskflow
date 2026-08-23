import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Service wrapping platform biometric capabilities.
/// Abstracts local_auth for testability and reuse.
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Whether the device has any biometric sensor enrolled.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (kDebugMode) {
        debugPrint(
            '[BiometricService] canCheckBiometrics=$canCheck, isDeviceSupported=$isDeviceSupported');
      }
      return canCheck || isDeviceSupported;
    } catch (e) {
      if (kDebugMode) debugPrint('[BiometricService] isAvailable error: $e');
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (fingerprint, face, iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      if (kDebugMode) {
        debugPrint('[BiometricService] available biometrics: $biometrics');
      }
      return biometrics;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricService] getAvailableBiometrics error: $e');
      }
      return [];
    }
  }

  /// Prompt the user for biometric authentication (fingerprint, face, etc.).
  /// Returns true on success, false if cancelled or failed.
  ///
  /// On Android this requires `FlutterFragmentActivity` in MainActivity.kt.
  /// On iOS this requires `NSFaceIDUsageDescription` in Info.plist.
  Future<bool> authenticate({
    String reason = 'Authenticate to unlock TaskFlow',
  }) async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/pattern as fallback
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
      if (kDebugMode) {
        debugPrint('[BiometricService] authenticate result=$result');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricService] authenticate error: $e');
      }
      return false;
    }
  }
}
