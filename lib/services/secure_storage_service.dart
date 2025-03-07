import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageService {
  // Create storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Encryption key storage key
  final String _encryptionKeyKey = 'encryption_key';
  
  // Get or generate encryption key
  Future<String> _getOrCreateEncryptionKey() async {
    String? encryptionKey = await _storage.read(key: _encryptionKeyKey);
    
    if (encryptionKey == null) {
      // Generate a random key for AES-256 (32 bytes)
      final key = encrypt.Key.fromSecureRandom(32);
      encryptionKey = base64Encode(key.bytes);
      await _storage.write(key: _encryptionKeyKey, value: encryptionKey);
    }
    
    return encryptionKey;
  }
  
  // Encrypt data
  Future<String> encryptData(String data) async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromLength(16); // AES uses 16 bytes for IV
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    
    // Return IV + encrypted data
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }
  
  // Decrypt data
  Future<String> decryptData(String encryptedData) async {
    final parts = encryptedData.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted data format');
    }
    
    final ivString = parts[0];
    final dataString = parts[1];
    
    final encryptionKey = await _getOrCreateEncryptionKey();
    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromBase64(ivString);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(dataString, iv: iv);
    
    return decrypted;
  }
  
  // Store encrypted data
  Future<void> secureWrite(String key, String value) async {
    String encryptedValue = await encryptData(value);
    await _storage.write(key: key, value: encryptedValue);
  }
  
  // Retrieve and decrypt data
  Future<String?> secureRead(String key) async {
    String? encryptedValue = await _storage.read(key: key);
    
    if (encryptedValue == null) {
      return null;
    }
    
    return await decryptData(encryptedValue);
  }
  
  // Delete data
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }
  
  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
  
  // Delete all data
  Future<void> deleteAllSecure() async {
    await _storage.deleteAll();
  }
} 