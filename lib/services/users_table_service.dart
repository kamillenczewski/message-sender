import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:messenger/db_models/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersTableService {
  final _db = Supabase.instance.client;
  final EncryptionController _encryptionController;
  final AccountEncryptor _accountEncryptor;

  UsersTableService(this._encryptionController, this._accountEncryptor);
  
  Future<void> add(String name, String password) async {
    await _db
      .from(Account.kTable)
      .insert(_accountEncryptor.encryptMap({
        Account.kName: name, 
        Account.kPassword: password
      }));
  }

  Future<bool> nameExists(String name) async {
    final response = await _db
      .from(Account.kTable)
      .select(Account.kName)
      .eq(Account.kName, _encryptionController.encryptText(name));

    return response.isNotEmpty;
  }

  Future<bool> checkPassword(String name, String password) async {
    final response = await _db
      .from(Account.kTable)
      .select('${Account.kName}, ${Account.kPassword}')
      .eq(Account.kName, _encryptionController.encryptText(name))
      .eq(Account.kPassword, password);

    return response.isNotEmpty;
  }

  Future<Account> getByName(String name) async {
    final response = await _db
      .from(Account.kTable)
      .select()
      .eq(Account.kName, _encryptionController.encryptText(name));
  
    return Account.fromMap(_accountEncryptor.decryptMap(response.first));
  }

  Future<String> getNameById(int id) async {
    final response = await _db
      .from(Account.kTable)
      .select()
      .eq(Account.kId, id);

    return _encryptionController.decryptText(response.first[Account.kName]);
  }

  Future<List<Account>> getAllExceptOne(int userId) async {
    final response = await _db
      .from(Account.kTable)
      .select()
      .neq(Account.kId, userId);

    return response.map((e) => Account.fromMap(_accountEncryptor.decryptMap(e))).toList();
  }
}