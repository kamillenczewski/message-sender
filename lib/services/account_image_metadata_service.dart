import 'package:messenger/db_models/account_image_metadata.dart';
import 'package:messenger/model_encryptors/account_image_metadata_encryptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountImageMetadataService {
  final _db = Supabase.instance.client;
  final AccountImageMetadataEncryptor _accountImageMetadataEncryptor;

  AccountImageMetadataService(this._accountImageMetadataEncryptor);
  
  Future<void> update(int accountId) async {
    final data = await _db
      .from(AccountImageMetadata.kTable)
      .select()
      .eq(AccountImageMetadata.kAccountId, accountId);
    
    if (data.isEmpty) {
      await _db
        .from(AccountImageMetadata.kTable)
        .insert(_accountImageMetadataEncryptor.encryptMap({
          AccountImageMetadata.kAccountId: accountId,
          AccountImageMetadata.kTimestamp: DateTime.now().millisecondsSinceEpoch,
        }));
    }
    else {
      await _db
        .from(AccountImageMetadata.kTable)
        .update(_accountImageMetadataEncryptor.encryptMap({
          AccountImageMetadata.kTimestamp: DateTime.now().millisecondsSinceEpoch,
        }))
        .eq(AccountImageMetadata.kAccountId, accountId);
    }
  }
}