import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/pages/login_page.dart';
import 'package:messenger/pages/register_page.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  static final String route = '/LoginOrRegisterPage';

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _settings.outerColor,
        alignment: .center,
        child: Column(
          spacing: 8,
          mainAxisAlignment: .center,
          children: [
            OperationButton(
              title: "Log In",
              onTap: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => LoginPage(),
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
                  )
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}