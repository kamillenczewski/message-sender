import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/secrets_controller.dart';

final getIt = GetIt.instance;

class EncryptionController {
  final SecretsController _secretsController;
  Key? _key;
  IV? _iv;

  EncryptionController(this._secretsController);

  Future<void> init() async {
    _key = Key.fromUtf8(await _secretsController.encryptionKey);
    _iv = IV.fromUtf8(await _secretsController.encryptionIV);
  }

  String encryptText(String plainText) {
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _iv!);
    return encrypted.base64;
  }

  String decryptText(String encryptedBase64) {
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(encryptedBase64);
    return encrypter.decrypt(encrypted, iv: _iv!);
  }

  List<int> encryptBytes(List<int> bytes) {
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv!);
    return encrypted.bytes;
  }

  List<int> decryptBytes(List<int> bytes) {
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    return encrypter.decryptBytes(
      Encrypted(Uint8List.fromList(bytes)),
      iv: _iv,
    );
  }
}