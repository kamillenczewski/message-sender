import 'package:messenger/model_encryptors/group_encryptor.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/db_models/group_account_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsTableService {
  final _db = Supabase.instance.client;
  final GroupEncryptor _groupEncryptor;

  GroupsTableService(this._groupEncryptor);
  
  Future<void> addGroup(String name, List<int> accountIds) async {
    final record = await _db
      .from(Group.kTable)
      .insert(_groupEncryptor.encryptMap({
        Group.kName: name, 
      }))
      .select();

    final groupId = record.first[Group.kId];

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