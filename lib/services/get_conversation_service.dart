import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/model_encryptors/group_encryptor.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/db_models/group_account_link.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetConversationService {
  final _db = Supabase.instance.client;
  final GroupEncryptor _groupEncryptor;
  final AccountController _accountController;

  GetConversationService(this._groupEncryptor, this._accountController);

  Future<Group> get(int accountId) async {
    final data = await _db
      .rpc(
        'conversation_for_accounts', 
        params: {
          'account_id_1': _accountController.account!.id, 
          'account_id_2': accountId
        }
      )
      as List<dynamic>;

    if (data.isNotEmpty) return Group.fromMap(_groupEncryptor.decryptMap(data.first));

    final record = await _db
      .from(Group.kTable)
      .insert(_groupEncryptor.encryptMap({
        Group.kName: Group.kNoNameTag,
        Group.kTypeId: 1
      }))
      .select();

    final group = Group.fromMap(_groupEncryptor.decryptMap(record.first));
    final conversationId = group.id;
    
    await _db
      .from(GroupAccountLink.kTable)
      .insert({
        GroupAccountLink.kGroupId: conversationId,
        GroupAccountLink.kAccountId: accountId
      });

    await _db
      .from(GroupAccountLink.kTable)
      .insert({
        GroupAccountLink.kGroupId: conversationId,
        GroupAccountLink.kAccountId: _accountController.account!.id
      });
    
    return group;
  }
} 