import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/model_encryptors/group_encryptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupNameService {
  final AccountController _accountController;
  final EncryptionController _encryptionController;
  final GroupEncryptor _groupEncryptor;
  final _db = Supabase.instance.client;

  GroupNameService(this._accountController, this._encryptionController, this._groupEncryptor);

  Future<String> get(int groupId) async {
    final groupData = await _db.from(Group.kTable).select().eq(Group.kId, groupId);
    final group = Group.fromMap(_groupEncryptor.decryptMap(groupData.first));

    if (group.typeId == 1 || group.name == Group.kNoNameTag) {
      final data = await _db
        .rpc(
          'account_names_for_given_account_and_group', 
          params: {
            'account_id_arg': _accountController.account!.id,
            'group_id_arg': group.id
          }
        ) as String;

      return _encryptionController.decryptText(data);
      // return data.map((e) => e[Account.kName] as String).join(', ');
    }    

    return group.name;
  }
} 