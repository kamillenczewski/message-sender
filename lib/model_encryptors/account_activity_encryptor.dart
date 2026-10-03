import 'package:messenger/model_encryptors/encryptor.dart';
import 'package:messenger/db_models/account_activity.dart';

class AccountActivityEncryptor {
  final Encryptor _encryptor;
  final _encryptionFields = [AccountActivity.kTimestamp];
  final _fieldTypes = [FieldType.integer];

  AccountActivityEncryptor(this._encryptor);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map) {
    return _encryptor.encryptMap(map, _encryptionFields);
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> map) {
    return _encryptor.decryptMap(map, _encryptionFields, _fieldTypes);
  }
}