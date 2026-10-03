import 'package:get_it/get_it.dart';
import 'package:messenger/db_models/account_image_metadata.dart';
import 'package:messenger/model_encryptors/encryptor.dart';

final getIt = GetIt.instance;

class AccountImageMetadataEncryptor {
  final Encryptor _encryptor;
  final _encryptionFields = [AccountImageMetadata.kTimestamp];
  final _fieldTypes = [FieldType.integer];

  AccountImageMetadataEncryptor(this._encryptor);

  Map<String, dynamic> encryptMap(Map<String, dynamic> map) {
    return _encryptor.encryptMap(map, _encryptionFields);
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> map) {
    return _encryptor.decryptMap(map, _encryptionFields, _fieldTypes);
  }
}