import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/session_controller.dart';
import 'package:messenger/dialogs/accept_action_dialog.dart';
import 'package:messenger/dialogs/add_conversation_or_group_dialog.dart';
import 'package:messenger/dialogs/select_account_image_dialog.dart';
import 'package:messenger/pages/widgets/custom_app_bar.dart';
import 'package:messenger/pages/groups_page/activity_bar.dart';
import 'package:messenger/pages/groups_page/group_section.dart';
import 'package:messenger/pages/groups_page/groups_widget.dart';
import 'package:messenger/pages/login_or_register_page.dart';
import 'package:messenger/pages/test_page.dart';
import 'package:messenger/controllers/settings.dart';

final getIt = GetIt.instance;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static final String route = '/MainPage';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _settings = Settings.instance;
  final _accountController = getIt<AccountController>();
  final _scrollController = ScrollController();
  final _sessionController = getIt<SessionController>();
  
  GroupSection _section = .all;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  PreferredSize createAppBar() {
    return createCustomAppBar(context,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            'Message Sender', 
            style: TextStyle(
              color: _settings.innerColor,
              fontFamily: _settings.fontFamily,
              fontSize: 25,
              fontWeight: .bold
            )
          ),
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .end,
            spacing: 16,
            children: [
              GestureDetector(
                child: Icon(Icons.add, color: _settings.innerColor, size: 30),
                onTap: () {
                  showAddConversationOrGroupDialog(context);
                },
              ),
              GestureDetector(
                child: Icon(Icons.photo_outlined, color: _settings.innerColor, size: 30),
                onTap: () {
                  showSelectAccountImageDialog(context);
                },
              ),
              GestureDetector(
                child: Icon(Icons.logout, color: _settings.innerColor, size: 30),
                onTap: () {
                  showAcceptActionDialog(context, 
                    onAccept: () async {
                      await _sessionController.deleteSession(_accountController.account!.id);
                      _accountController.logOut();
                      
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => LoginOrRegisterPage(),
                        )
                      );
                    },
                    text: 'Are you sure you want to log out?',
                    direction: .horizontal,
                    buttonWidth: 100
                  );
                },
              )
            ],
          ),
        ],
      )
    );
  }

  Widget createSectionButton(GroupSection section) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: _section == section ? const Color.fromARGB(255, 0, 47, 130) : const Color.fromARGB(255, 41, 41, 41),
            borderRadius: .circular(8)
          ),
          padding: .only(top: 4, bottom: 4),
          child: Text(
            section.name, 
            textAlign: .center,
            style: TextStyle(
              color: _section == section ? Colors.blue : _settings.middleColor,
              fontFamily: _settings.fontFamily,
              fontSize: 15                    
            )
          ),
        ),
        onTap: () {
          setState(() {
            _section = section;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: Container(
        padding: .only(top: 10),
        color: _settings.outerColor,
        child: ListenableBuilder(
          listenable: _accountController,
          builder: (context, child) {
            return Column(
              spacing: 8,
              children: [
                true == false 
                ?
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => TestPage()
                      )
                    );
                  },
                  child: Text(
                    'Test',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  )
                )
                : 
                SizedBox.shrink(),

                ActivityBar(),
                Padding(
                  padding: const .all(10),
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: .center,
                    children: [
                      createSectionButton(GroupSection.all),
                      createSectionButton(GroupSection.conversations),
                      createSectionButton(GroupSection.groups),
                    ],
                  ),
                ),
                GroupsWidget(section: _section),
              ],
            );
          }
        ),
      )
    );
  }
}