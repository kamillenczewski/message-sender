import 'dart:convert';
import 'package:flutter/services.dart';

class SecretsController {
  Map<String, String> _secrets = {};
  
  Future<void> init() async {
    final text = await rootBundle.loadString('secrets.json');
    final obj = json.decode(text) as Map<String, dynamic>;
    _secrets = obj.map((key, value) => MapEntry(key, value as String));
  }

  Future<String> get dbUrl async => _secrets['DB-URL']!;
  Future<String> get dbKey async => _secrets['DB-KEY']!;
  Future<String> get encryptionKey async => _secrets['ENCRYPT-KEY']!;
  Future<String> get encryptionIV async => _secrets['ENCRYPT-IV']!;
}