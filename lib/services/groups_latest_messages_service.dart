import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/db_models/group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class GroupsLatestMessagesService {
  final _db = Supabase.instance.client;
  final EncryptionController _encryptionController;
  final AccountController _accountController;

  GroupsLatestMessagesService(this._encryptionController, this._accountController);

  String _handleStringNull(String? obj) {
    if (obj == null) return '';
    return _encryptionController.decryptText(obj);
  }

  int _handleIntNull(String? obj) {
    if (obj == null) return 0;
    return int.parse(_encryptionController.decryptText(obj));
  }

  Future<List<({Group group, String accountName, String content, int datetime})>> get() async {
    final data = await _db
      .rpc(
        'latest_group_messages_view', 
        params: {
          'current_account_id': _accountController.account!.id
        }
      )
      as List<dynamic>;

    final decrypted = data.map(
      (e) => (
        group: Group(e['group_id'], _encryptionController.decryptText(e['group_name']), e['group_type_id']),
        accountName: _handleStringNull(e['account_name']), 
        content: _handleStringNull(e['content']), 
        datetime: _handleIntNull(e['datetime'])
      )
    ).toList();

    return decrypted;
  }

  Future<List<({Group group, String accountName, String content, int datetime})>> getConversations() async {
    return (await get()).where((e) => e.group.typeId == 1).toList();
  }

  Future<List<({Group group, String accountName, String content, int datetime})>> getNotConversations() async {
    return (await get()).where((e) => e.group.typeId == 0).toList();
  }
}