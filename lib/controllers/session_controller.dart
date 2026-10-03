import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/account_session.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SessionController {
  final _db = Supabase.instance.client;
  final AccountEncryptor _accountEncryptor;
  final AccountController _accountController;

  final kSessionFile = '${Directory.systemTemp.path}/flutter_message_sender_session_hashcode.txt';

  SessionController(this._accountEncryptor, this._accountController);

  Future<bool> tryLoadSession() async {
    final file = File(kSessionFile);

    if (!file.existsSync()) return false;

    final content = file.readAsStringSync();

    final potentialRecord = await _db
      .from(AccountSession.kTable)
      .select()
      .eq(AccountSession.kHashcode, content)
      .eq(AccountSession.kDeviceId, await getDeviceId());
    
    if (potentialRecord.isEmpty) return false;

    final accountData = await _db
      .from(Account.kTable)
      .select()
      .eq(Account.kId, potentialRecord.first[AccountSession.kAccountId]);

    final account = Account.fromMap(_accountEncryptor.decryptMap(accountData.first));

    await _accountController.logIn(account.name);

    return true;
  }

  Future<void> deleteSession(int accountId) async {
    final deviceId = await getDeviceId();

    await _db
      .from(AccountSession.kTable)
      .delete()
      .eq(AccountSession.kAccountId, accountId)
      .eq(AccountSession.kDeviceId, deviceId);

    File(kSessionFile).deleteSync();
  }

  Future<void> createSession(int accountId) async {
    String sessionHashcode = Uuid().v4().replaceAll('-', '');

    await updateSessionInDb(accountId, sessionHashcode);
    await updateSessionInDevice(sessionHashcode);
  }

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      return (await DeviceInfoPlugin().androidInfo).model;
    }
    else {
      return (await DeviceInfoPlugin().windowsInfo).deviceId;
    }
  }

  Future<void> updateSessionInDevice(String hashcode) async {
    File(kSessionFile)..createSync()..writeAsStringSync(hashcode);
  }

  Future<void> updateSessionInDb(int accountId, String newHashcode) async {
    final deviceId = await getDeviceId();

    final potentialRecord = await _db
      .from(AccountSession.kTable)
      .select()
      .eq(AccountSession.kAccountId, accountId)
      .eq(AccountSession.kDeviceId, deviceId);
    
    if (potentialRecord.isNotEmpty) {
      await _db
        .from(AccountSession.kTable)
        .update({AccountSession.kHashcode: newHashcode})
        .eq(AccountSession.kAccountId, accountId)
        .eq(AccountSession.kDeviceId, deviceId);
    }
    else {
      await _db
        .from(AccountSession.kTable)
        .insert({
          AccountSession.kAccountId: accountId,
          AccountSession.kDeviceId: deviceId,
          AccountSession.kHashcode: newHashcode
        });
    }
  }
}