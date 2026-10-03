import 'package:get_it/get_it.dart';
import 'package:messenger/model_encryptors/encryptor.dart';
import 'package:messenger/db_models/account.dart';

final getIt = GetIt.instance;

class AccountEncryptor {
  final Encryptor _encryptor;
  final _encryptionFields = [Account.kName];
  final _fieldTypes = [FieldType.string];

  AccountEncryptor(this._encryptor);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map) {
    return _encryptor.encryptMap(map, _encryptionFields);
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> map) {
    return _encryptor.decryptMap(map, _encryptionFields, _fieldTypes);
  }
}