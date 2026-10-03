import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String text) {
  final key = "-9n129 20984c08nv214v21x4,149148939843478n9kksjidsfd";
  final hmac = Hmac(sha256, utf8.encode(key));
  final hash = hmac.convert(utf8.encode(text)).toString();
  return hash;
}