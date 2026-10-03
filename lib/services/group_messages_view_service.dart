import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/model_encryptors/group_message_encryptor.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupMessagesViewService {
  final _db = Supabase.instance.client;
  final EncryptionController _encryptionController;
  final GroupMessageEncryptor _groupMessageEncryptor;

  GroupMessagesViewService(this._encryptionController, this._groupMessageEncryptor);

  // Future<List<(List<GroupMessage>, String)>> getMessagesByGroup(int groupId) async {
  //   final data = await _db
  //     .from(GroupMessage.kTable)
  //     .select("""
  //       *,
  //       ${Account.kTable}(${Account.kName})
  //     """)
  //     .eq(GroupMessage.kGroupId, groupId)
  //     .order(GroupMessage.kId, ascending: true);

  //   if (data.isEmpty) return [];

  //   var messagesAndNames = <(List<GroupMessage>, String)>[];
  //   var currentList = <GroupMessage>[];
  //   String currentName = _encryptionController.decryptText(data[0][Account.kTable][Account.kName]);
        
  //   for (var record in data) {    
  //     final name = _encryptionController.decryptText(record[Account.kTable][Account.kName]);
  //     final message = GroupMessage.fromMap(_groupMessageEncryptor.decryptMap(record));

  //     if (name == currentName) {
  //       currentList.add(message);
  //     }
  //     else {
  //       messagesAndNames.add((currentList, currentName));
  //       currentName = name;
  //       currentList = [message];
  //     }
  //   }

  //   messagesAndNames.add((currentList, currentName));

  //   return messagesAndNames.reversed.toList();
  // }

  Future<List<(List<GroupMessage>, String, int)>> getMessagesByGroup_NEW(int groupId) async {
    final data = await _db
      .from(GroupMessage.kTable)
      .select("""
        *,
        ${Account.kTable}(${Account.kName}, ${Account.kId})
      """)
      .eq(GroupMessage.kGroupId, groupId)
      .order(GroupMessage.kId, ascending: true);

    if (data.isEmpty) return [];

    var messagesAndNames = <(List<GroupMessage>, String, int)>[];
    var currentList = <GroupMessage>[];

    String currentName = _encryptionController.decryptText(data[0][Account.kTable][Account.kName]);
    int currentId = data[0][Account.kTable][Account.kId];
        
    for (var record in data) {    
      final name = _encryptionController.decryptText(record[Account.kTable][Account.kName]);
      final message = GroupMessage.fromMap(_groupMessageEncryptor.decryptMap(record));

      if (name == currentName) {
        currentList.add(message);
      }
      else {
        messagesAndNames.add((currentList, currentName, currentId));
        currentName = name;
        currentId = record[Account.kTable][Account.kId];
        currentList = [message];
      }
    }

    messagesAndNames.add((currentList, currentName, currentId));

    return messagesAndNames.reversed.toList();
  }
}