import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group_account_link.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountsWithConversationsViewService {
  final _db = Supabase.instance.client;
  final EncryptionController _encryptionController;
  final AccountController _accountController;
  final AccountEncryptor _accountEncryptor;

  AccountsWithConversationsViewService(this._encryptionController, this._accountController, this._accountEncryptor);
  
  Future<Map<int, List<Account>>> getForAllGroups() async {
    final data = await _db
      .rpc('accounts_with_conversations_view', params: {'current_account_id': _accountController.account!.id})
      as List<dynamic>;

    
    final decrypted = data.map(
      (e) => (
        groupId: e['group_id'] as int,
        account: Account(
          e['account_id'], 
          _encryptionController.decryptText(e['account_name']), 
          e['account_password']
        )
      )
    ).toList();

    final Map<int, List<Account>> accountsMap = {};

    for (final record in decrypted) {
      if (accountsMap.containsKey(record.groupId)) {
        accountsMap[record.groupId]!.add(record.account);
      }
      else {
        accountsMap[record.groupId] = [record.account];
      }
    }

    return accountsMap;
  }

  Future<Map<int, List<Account>>> getForAllGroups_NEW() async {
    final data = await _db
      .from(GroupAccountLink.kTable)
      .select("""
        ${GroupAccountLink.kGroupId},
        ${Account.kTable}(*)
      """);

    final decrypted = data.map(
      (e) => (
        groupId: e[GroupAccountLink.kGroupId] as int,
        account: Account.fromMap(_accountEncryptor.decryptMap(e[Account.kTable]))
      )
    ).toList();

    Map<int, List<Account>> accountsMap = {};

    for (final record in decrypted) {
      if (accountsMap.containsKey(record.groupId)) {
        accountsMap[record.groupId]!.add(record.account);
      }
      else {
        accountsMap[record.groupId] = [record.account];
      }
    }

    for (final entry in accountsMap.entries.toList()) {
      if (!entry.value.map((e) => e.id).contains(_accountController.account!.id)) {
        accountsMap.remove(entry.key);
      }
    }

    return accountsMap;
  }


  Future<List<Account>> getForGroup(int groupId) async {
    final data = await _db
      .from(GroupAccountLink.kTable)
      .select("""
        ${Account.kTable}(*)
      """)
      .eq(GroupAccountLink.kGroupId, groupId);

    return data.map((e) => Account.fromMap(_accountEncryptor.decryptMap(e[Account.kTable]))).toList();
  }
}