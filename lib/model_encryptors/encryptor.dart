import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/encryption_controller.dart';

final getIt = GetIt.instance;

enum FieldType {string, integer}

class Encryptor {
  final EncryptionController _encryptionController;

  Encryptor(this._encryptionController);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map, List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      map[fieldName] = _encryptionController.encryptText(map[fieldName].toString());
    }

    return map;
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> map, List<String> fieldNames, List<FieldType> fieldTypes) {
    for (var i = 0; i < fieldNames.length; i++) {
      if (fieldTypes[i] == FieldType.integer) {
        map[fieldNames[i]] = int.parse(_encryptionController.decryptText(map[fieldNames[i]]));
      }
      else {
        map[fieldNames[i]] = _encryptionController.decryptText(map[fieldNames[i]]);
      }
    }

    return map;
  }
}