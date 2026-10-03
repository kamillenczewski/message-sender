import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/session_controller.dart';
import 'package:messenger/pages/groups_page/main_page.dart';
import 'package:messenger/utils.dart';
import 'package:messenger/widgets/operation_button.dart';
import 'package:messenger/widgets/already_logged_in_widget.dart';
import 'package:messenger/widgets/custom_text_field.dart';
import 'package:messenger/widgets/forms_container.dart';
import 'package:messenger/services/users_table_service.dart';
import 'package:messenger/controllers/settings.dart';

final getIt = GetIt.instance;

enum InformationText { 
  empty(null),
  nameAlreadyExists('Entered name already exists!'), 
  inconsistentPasswords('Entered passwords are inconsistent!');
  
  final String? content;

  const InformationText(this.content);
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static final String route = '/RegisterPage';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatedPasswordController = TextEditingController();
  final _settings = Settings.instance;
  final _usersTableService = getIt<UsersTableService>();
  final _accountController = getIt<AccountController>();
  final _sessionController = getIt<SessionController>();
  InformationText _informationText = .empty;

  Widget createInformationWidget() {
    if (_informationText.content == null) return SizedBox.shrink();

    return Text(
      _informationText.content!, 
      textAlign: .center,
      style: TextStyle(
        color: _settings.innerColor, 
        fontFamily: _settings.fontFamily,
        fontWeight: .bold,
        fontSize: 15
      )
    );
  }

  Future<void> _handleSubmit() async {
    InformationText info = .empty;
    final name = _nameController.text;
    final password = _passwordController.text;
    final repeatedPassword = _repeatedPasswordController.text;

    if (await _usersTableService.nameExists(name)) {
      info = .nameAlreadyExists;
    }
    else if (password != repeatedPassword) {
      info = .inconsistentPasswords;
    }

    setState(() {
      _informationText = info;
    });

    if (info != .empty) return;

    await _accountController.register(name, hashPassword(password));
    await _sessionController.createSession(_accountController.account!.id);

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MainPage(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_accountController.account != null) {
      return createAlreadyLoggedInWidget(setState);
    }

    return Scaffold(
      body: Container(
        color: _settings.outerColor,
        alignment: .center,
        child: FormsContainer(
          title: 'Register', 
          textFields: [
            createCustomTextField(
              controller: _nameController, 
              hintLabel: 'Name'
            ),
            createCustomTextField(
              controller: _passwordController, 
              hintLabel: 'Password',
              isObscure: true
            ),
            createCustomTextField(
              controller: _repeatedPasswordController, 
              hintLabel: 'Repeat Password',
              isObscure: true,
              onEditingComplete: () async => await _handleSubmit()
            ),
            createInformationWidget(),
            OperationButton(
              title: 'Submit',
              onTap: () async => await _handleSubmit(),
            ),
            OperationButton(
              title: 'Back',
              onTap: () => Navigator.of(context).pop(),
              reversedColors: false
            ),
          ],
        ),
      ),
    );
  }
}