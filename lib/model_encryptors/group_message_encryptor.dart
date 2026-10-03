import 'package:get_it/get_it.dart';
import 'package:messenger/model_encryptors/encryptor.dart';
import 'package:messenger/db_models/group_message.dart';

final getIt = GetIt.instance;

class GroupMessageEncryptor {
  final Encryptor _encryptor;
  final List<String> _encryptionFields = [GroupMessage.kContent, GroupMessage.kDatetime];
  final List<FieldType> _fieldTypes = [FieldType.string, FieldType.integer];

  GroupMessageEncryptor(this._encryptor);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map) {
    return _encryptor.encryptMap(map, _encryptionFields);
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> map) {
    return _encryptor.decryptMap(map, _encryptionFields, _fieldTypes);
  }
}