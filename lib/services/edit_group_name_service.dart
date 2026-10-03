import 'package:get_it/get_it.dart';
import 'package:messenger/model_encryptors/group_encryptor.dart';
import 'package:messenger/db_models/group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class EditGroupNameService {
  final _db = Supabase.instance.client;
  final GroupEncryptor _groupEncryptor;

  EditGroupNameService(this._groupEncryptor);
  
  Future<void> edit(int groupId, String name) async {
    await _db
      .from(Group.kTable)
      .update(_groupEncryptor.encryptMap({
        Group.kName: name
      }))
      .eq(Group.kId, groupId);
  }
}