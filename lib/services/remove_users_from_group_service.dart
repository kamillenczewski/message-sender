import 'package:messenger/db_models/group_account_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoveUsersFromGroupService {
  final _db = Supabase.instance.client;

  RemoveUsersFromGroupService();
  
  Future<void> remove(int groupId, int accountId) async {
    await _db  
      .from(GroupAccountLink.kTable)
      .delete()
      .eq(GroupAccountLink.kGroupId, groupId)
      .eq(GroupAccountLink.kAccountId, accountId);
  }
}