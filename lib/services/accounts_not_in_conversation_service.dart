import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:messenger/db_models/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountsNotInConversationService {
  final _db = Supabase.instance.client;
  final AccountEncryptor _accountEncryptor;
  final AccountController _accountController;

  AccountsNotInConversationService(this._accountEncryptor, this._accountController);
  
  Future<List<Account>> get() async {
    final data = await _db
      .rpc(
        'get_accounts_not_in_conversation_with_account', 
        params: {
          'account_id_arg': _accountController.account!.id
        }
      )
      as List<dynamic>;

    return data.map((e) => Account.fromMap(_accountEncryptor.decryptMap(e))).toList();
  }
}