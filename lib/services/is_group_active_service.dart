import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class IsGroupActiveService {
  final _db = Supabase.instance.client;
  final EncryptionController _encryptionController; 

  IsGroupActiveService(this._encryptionController);

  Future<bool> execute(int groupId) async {
    final data = await _db
      .rpc(
        'group_activities', 
        params: {
          'group_id_arg': groupId
        }
      )
      as List<dynamic>;

    final minTime = DateTime.now().millisecondsSinceEpoch - AccountActivity.kMaxDelayInMiliseconds;

    return data
      .map(
        (e) => (
          int.parse(_encryptionController.decryptText(e[AccountActivity.kTimestamp])),
        )
      )
      .where((e) => e.$1 >= minTime)
      .isNotEmpty;
  }
}