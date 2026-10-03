import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:messenger/db_models/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountsNotInGroupService {
  final _db = Supabase.instance.client;
  final AccountEncryptor _accountEncryptor;

  AccountsNotInGroupService(this._accountEncryptor);
  
  Future<List<Account>> get(int groupId) async {
    final data = await _db
      .rpc('get_accounts_not_in_group', params: {'group_id_arg': groupId})
      as List<dynamic>;

    return data.map((e) => Account.fromMap(_accountEncryptor.decryptMap(e))).toList();
  }
}