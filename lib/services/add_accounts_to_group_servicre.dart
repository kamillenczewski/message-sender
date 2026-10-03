import 'package:messenger/db_models/group_account_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAccountsToGroupServicre {
  final _db = Supabase.instance.client;

  AddAccountsToGroupServicre();
  
  Future<void> add(int groupId, List<int> accountIds) async {
    for (final accountId in accountIds) {
      await _db
        .from(GroupAccountLink.kTable)
        .insert({
          GroupAccountLink.kGroupId: groupId,
          GroupAccountLink.kAccountId: accountId,
        });
    }
  }
}