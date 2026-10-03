import 'package:messenger/model_encryptors/account_activity_encryptor.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountActivitiesTableService {
  final _db = Supabase.instance.client;
  final AccountActivityEncryptor _accountActivityEncryptor;
  final AccountEncryptor _accountEncryptor;

  AccountActivitiesTableService(this._accountActivityEncryptor, this._accountEncryptor);
  
  Future<void> update(int accountId) async {
    await _db
      .from(AccountActivity.kTable)
      .update(_accountActivityEncryptor.encryptMap({
        AccountActivity.kTimestamp: DateTime.now().millisecondsSinceEpoch
      }))
      .eq(AccountActivity.kAccountId, accountId);
  }

  Future<void> add(int accountId) async {
    await _db
      .from(AccountActivity.kTable)
      .insert(_accountActivityEncryptor.encryptMap({
        AccountActivity.kAccountId: accountId,
        AccountActivity.kTimestamp: DateTime.now().millisecondsSinceEpoch
      }));
  }

  Future<bool> exists(int accountId) async {
    final record = await _db
      .from(AccountActivity.kTable)
      .select(AccountActivity.kAccountId)
      .eq(AccountActivity.kAccountId, accountId);
    
    return record.isNotEmpty;
  }

  Future<List<Account>> getActiveAccounts(Account account) async {
    final minTime = DateTime.now().millisecondsSinceEpoch - AccountActivity.kMaxDelayInMiliseconds;

    final data = await _db
      .from(AccountActivity.kTable)
      .select("""
        *,
        ${Account.kTable}(*)
      """)
      .neq(AccountActivity.kAccountId, account.id);

    return [account] + data
      .map((e) => 
        (
          AccountActivity.fromMap(_accountActivityEncryptor.decryptMap(e)), 
          Account.fromMap(_accountEncryptor.decryptMap(e[Account.kTable]))
        )
      )
      .where((e) => e.$1.timestamp >= minTime)
      .map((e) => e.$2)
      .toList();
  }
}