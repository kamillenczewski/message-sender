import 'package:flutter/material.dart';
import 'package:messenger/pages/login_page.dart';
import 'package:messenger/pages/register_page.dart';
import 'package:messenger/widgets/operation_button.dart';

Widget createLoginOrRegisterWidget(BuildContext context) {
  return Column(
    spacing: 8,
    mainAxisAlignment: .center,
    children: [
      OperationButton(
        title: "Log In",
        onTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => LoginPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (_, _, _, child) => child,
            )
          );
        }
      ),
      OperationButton(
        title: "Register",
        onTap: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => RegisterPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (_, _, _, child) => child,
            )
          );
        }
      ),
    ],
  );
}