import 'package:get_it/get_it.dart';
import 'package:messenger/model_encryptors/encryptor.dart';
import 'package:messenger/db_models/group.dart';

final getIt = GetIt.instance;

class GroupEncryptor {
  final Encryptor _encryptor;
  final List<String> _encryptionFields = [Group.kName];
  final List<FieldType> _fieldTypes = [FieldType.string];

  GroupEncryptor(this._encryptor);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map) =>
    _encryptor.encryptMap(map, _encryptionFields);

  Map<String, dynamic> decryptMap(Map<String, dynamic> map) =>
    _encryptor.decryptMap(map, _encryptionFields, _fieldTypes);
}