import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/widgets/operation_button.dart';

Widget createAlreadyLoggedInWidget(
  void Function(void Function()) setState
) {
  final settings = Settings.instance;
  final getIt = GetIt.instance;
  final accountController = getIt<AccountController>();

  return Column(
    spacing: 8,
    mainAxisAlignment: .center,
    children: [
      Text(
        "You have already logged in!",
        textAlign: .center,
        style: TextStyle(
          color: settings.innerColor, 
          fontFamily: settings.fontFamily,
          fontWeight: .bold,
          fontSize: 15
        )
      ),
      OperationButton(
        title: "Log Out",
        onTap: () {
          setState(() {
            accountController.logOut();
          });
        }
      )
    ],
  );
}