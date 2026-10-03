import 'package:get_it/get_it.dart';
import 'package:messenger/model_encryptors/group_message_encryptor.dart';
import 'package:messenger/db_models/group_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class MessagesTableService {
  final _db = Supabase.instance.client;
  final GroupMessageEncryptor _groupMessageEncryptor;

  MessagesTableService(this._groupMessageEncryptor);

  Future<void> add(int userId, int groupId, String content) async {
    await _db
      .from(GroupMessage.kTable)
      .insert(_groupMessageEncryptor.encryptMap({
        GroupMessage.kUserId: userId, 
        GroupMessage.kGroupId: groupId, 
        GroupMessage.kContent: content, 
        GroupMessage.kDatetime: DateTime.now().millisecondsSinceEpoch
      }));
  }
}