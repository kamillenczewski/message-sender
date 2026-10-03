import 'package:flutter/material.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/services/account_activities_table_service.dart';
import 'package:messenger/services/users_table_service.dart';

class AccountController extends ChangeNotifier {
  final UsersTableService _usersTableService;
  final AccountActivitiesTableService _accountActivitiesTableService;

  Account? account;

  AccountController(this._usersTableService, this._accountActivitiesTableService);

  final kDelay = 30*1000;

  Future<void> _sendActivity() async {
    if (!await _accountActivitiesTableService.exists(account!.id)) {
      await _accountActivitiesTableService.add(account!.id);
    }

    while(true) {
      if (account == null) break;
      await _accountActivitiesTableService.update(account!.id);
      await Future<void>.delayed(Duration(milliseconds: kDelay));
    }
  }

  Future<void> logIn(String name) async {
    account = await _usersTableService.getByName(name);
    _sendActivity();
    notifyListeners();
  }

  void logOut() {
    account = null;
    notifyListeners();
  }

  Future<void> register(String name, String password) async {
    await _usersTableService.add(name, password);
    account = await _usersTableService.getByName(name);
    _sendActivity();
    notifyListeners();
  }
}