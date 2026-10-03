import 'package:get_it/get_it.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:messenger/model_encryptors/account_activity_encryptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class SecondsSinceLastActivityService {
  final _db = Supabase.instance.client;
  final AccountActivityEncryptor _accountActivityEncryptor; 

  SecondsSinceLastActivityService(this._accountActivityEncryptor);

  Future<int> get(int accountId) async {
    final data = await _db
      .from(AccountActivity.kTable)
      .select()
      .eq(AccountActivity.kAccountId, accountId);
    
    final timeValue = data
      .map((e) => AccountActivity.fromMap(_accountActivityEncryptor.decryptMap(e)))
      .first
      .timestamp;

    return ((DateTime.now().millisecondsSinceEpoch - timeValue) / 1000).round();
  }
}