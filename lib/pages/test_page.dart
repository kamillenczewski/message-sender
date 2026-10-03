import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/session_controller.dart';
import 'package:messenger/pages/widgets/custom_app_bar.dart';

final getIt = GetIt.instance;

class TestPage extends StatefulWidget {
  const TestPage({
    super.key, 
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: createCustomAppBar(context),
      body: Row(
        spacing: 10,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back, color: Colors.white,)
          ),
          GestureDetector(
            onTap: () async {
              
              getIt<SessionController>().createSession(getIt<AccountController>().account!.id);
            },
            child: Text("DOOO",  style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }
}