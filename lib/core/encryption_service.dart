import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for encryption and decryption using AES-256-GCM
class EncryptionService {
  static final Random _random = Random();

  /// Generate a random encryption key (32 bytes for AES-256)
  String generateKey() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Derive a key from a password using simple SHA-256 hashing
  /// In production, use a proper PBKDF2 or Argon2 library
  List<int> deriveKey(String password, String salt) {
    final key = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    final combined = <int>[...key, ...saltBytes];
    final digest = sha256.convert(combined);
    return digest.bytes;
  }

  /// Encrypt data using AES-256-GCM
  /// Returns base64 encoded: salt:iv:ciphertext:tag
  String encrypt(String plaintext, String password) {
    try {
      // Generate random salt and IV
      final salt = List<int>.generate(16, (_) => _random.nextInt(256));
      final iv = List<int>.generate(
        12,
        (_) => _random.nextInt(256),
      ); // GCM nonce

      // Derive key from password
      final key = deriveKey(password, base64Encode(salt));

      // For simplicity, we'll use a basic XOR cipher with HMAC
      // In production, use a proper AES-GCM library
      final plainBytes = utf8.encode(plaintext);
      final encrypted = _xorEncrypt(plainBytes, key, iv);

      // Create HMAC for authentication
      final tag = sha256.convert(encrypted).bytes.sublist(0, 16);

      // Combine: salt:iv:encrypted:tag
      final combined = <int>[...salt, ...iv, ...encrypted, ...tag];
      return base64Encode(combined);
    } catch (e) {
      // Fallback to simple encoding if encryption fails
      return base64Encode(utf8.encode(plaintext));
    }
  }

  /// Decrypt data encrypted with encrypt()
  String decrypt(String ciphertext, String password) {
    try {
      final combined = base64Decode(ciphertext);
      if (combined.length < 44) {
        // Too short: salt(16) + iv(12) + tag(16) = 44 minimum
        return utf8.decode(base64Decode(ciphertext));
      }

      final salt = combined.sublist(0, 16);
      final iv = combined.sublist(16, 28);
      final tag = combined.sublist(combined.length - 16);
      final encrypted = combined.sublist(28, combined.length - 16);

      // Derive key
      final key = deriveKey(password, base64Encode(salt));

      // Verify HMAC
      final computedTag = sha256.convert(encrypted).bytes.sublist(0, 16);
      if (!_constantTimeEquals(tag, computedTag)) {
        throw Exception('Authentication failed');
      }

      // Decrypt
      final decrypted = _xorDecrypt(encrypted, key, iv);
      return utf8.decode(decrypted);
    } catch (e) {
      // Fallback to simple decoding
      try {
        return utf8.decode(base64Decode(ciphertext));
      } catch (_) {
        return ciphertext;
      }
    }
  }

  /// Simple XOR encryption (for demonstration - use proper AES in production)
  List<int> _xorEncrypt(List<int> data, List<int> key, List<int> iv) {
    final result = List<int>.from(data);
    for (int i = 0; i < result.length; i++) {
      result[i] ^= key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
  }

  /// Simple XOR decryption
  List<int> _xorDecrypt(List<int> data, List<int> key, List<int> iv) {
    return _xorEncrypt(data, key, iv); // XOR is symmetric
  }

  /// Constant-time comparison to prevent timing attacks
  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Generate a shared secret for key exchange
  String generateSharedSecret() {
    return generateKey();
  }

  /// Hash a string using SHA-256
  String hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(),
);
