import 'package:messenger/db_models/group_account_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupAccountLinksTableService {
  final _db = Supabase.instance.client;

  GroupAccountLinksTableService();
  
  Future<void> delete(int accountId, int groupId) async {
    await _db
      .from(GroupAccountLink.kTable)
      .delete()
      .eq(GroupAccountLink.kGroupId, groupId)
      .eq(GroupAccountLink.kAccountId, accountId);
  }

  Future<void> add(int accountId, int groupId) async {
    await _db
      .from(GroupAccountLink.kTable)
      .insert({
        GroupAccountLink.kGroupId: groupId,
        GroupAccountLink.kAccountId: accountId,
      });
  }
}