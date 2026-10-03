import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/pages/choose_user_to_conversation_page.dart';
import 'package:messenger/pages/choose_users_to_group_page.dart';

Widget createOptionButton({
  required String title, 
  required IconData icon, 
  required void Function() onTap
}) {
  final settings = Settings.instance;

  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: settings.outerColor,
              border: BoxBorder.all(color: settings.innerColor)
            ),
            padding: .all(12),
            child: Row(
              spacing: 8,
              children: [
                Icon(icon, color: settings.innerColor),
                Text(
                  title, 
                  textAlign: .center,
                  style: TextStyle(
                    fontFamily: settings.fontFamily, 
                    fontSize: 18, 
                    color: settings.innerColor
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

void showAddConversationOrGroupDialog(BuildContext context) {
  final settings = Settings.instance;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: settings.outerColor,
            border: BoxBorder.all(color: settings.innerColor)
          ),
          width: 350,
          padding: const .all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              createOptionButton(
                title: 'Create new group', 
                icon: Icons.forum,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => ChooseUsersToGroupPage(),
                    )
                  );
                }
              ),
              createOptionButton(
                title: 'Start a conversation', 
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => ChooseUserToConversationPage(),
                    )
                  );
                } 
              ),
            ],
          ),
        )
      );
    },
  );
}