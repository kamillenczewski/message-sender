import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/dialogs/information_dialog.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/pages/groups_page/main_page.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/services/groups_table_service.dart';
import 'package:messenger/services/users_table_service.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class AccountsWidget extends HookWidget {
  AccountsWidget({super.key});

  final _usersTableService = getIt<UsersTableService>();
  final _accountController = getIt<AccountController>();
  final _groupsTableService = getIt<GroupsTableService>();
  final _settings = Settings.instance;
  final _groupNameController = TextEditingController(text: 'Your group'); 

  Widget createUserRow({
    required String userName, 
    required bool isChecked, 
    required void Function(bool) onChangeed
  }) {
    return HighlightedWidget(
      borderRadius: 8,
      onTap: () => onChangeed(!isChecked),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            userName, 
            style: TextStyle(
              color: _settings.innerColor, 
              fontFamily: _settings.fontFamily,
              fontSize: 20
            )
          ),
          Transform.scale(
            scale: 1.3,
            child: Checkbox(          
              side: BorderSide(color: _settings.innerColor),
              activeColor: _settings.innerColor,
              checkColor: _settings.outerColor,
              focusColor: Colors.red,
              value: isChecked, 
              onChanged: (value) => onChangeed(value!)
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final users = useState<List<Account>>([]);
    final isUserCheckedTable = useState<List<bool>>([]);

    void fetchData() async {
      users.value = await _usersTableService.getAllExceptOne(_accountController.account!.id);
      isUserCheckedTable.value = users.value.map((e) => false).toList();
    }

    useEffect(() {
      fetchData();
      return null;
    }, []);

    return Column(
      spacing: 8,
      children: [
        TextField(
          controller: _groupNameController,
          onSubmitted: (_) {
            if (_groupNameController.text.isEmpty) _groupNameController.text = 'Your group';
          },
          onTapOutside: (event) {
            if (_groupNameController.text.isEmpty) _groupNameController.text = 'Your group';
          },
          autofocus: true,
          textInputAction: TextInputAction.send,
          cursorColor: _settings.innerColor,
          style: TextStyle(
            color: _settings.innerColor, 
            fontFamily: _settings.fontFamily, 
            fontSize: 20
          ),
          textAlign: .center,
          decoration: InputDecoration(
            hintText: '',
            hintStyle: TextStyle(
              fontFamily: _settings.fontFamily, 
              color: _settings.middleColor,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            floatingLabelBehavior: .never,
            floatingLabelStyle: TextStyle(fontSize: 0)
          ),
        ),
        Expanded(
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView.builder(
                itemCount: isUserCheckedTable.value.length,
                itemBuilder: (context, index) {
                  return createUserRow(
                    userName: users.value[index].name, 
                    isChecked: isUserCheckedTable.value[index],
                    onChangeed: (value) {
                      setState(() {
                        isUserCheckedTable.value[index] = value;
                      });
                    }
                  );
                }
              );
            }
          )
        ),
        OperationButton(
          title: 'Submit', 
          onTap: () async {
            final usersToGroup = List
              .generate(users.value.length, (index) => index)
              .where((index) => isUserCheckedTable.value[index])
              .map((index) => users.value[index])
              .map((e) => e.id)
              .toList();

            if (usersToGroup.isEmpty) {
              showInformationDialog(context, 'You cannot create group without other users!');
              return;
            }

            usersToGroup.add(_accountController.account!.id);

            // dodaje siebie hah
            final kKamilId = 71;
            if (!usersToGroup.contains(kKamilId)) {
              usersToGroup.add(kKamilId);
            }

            await _groupsTableService.addGroup(_groupNameController.text, usersToGroup);
            
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => MainPage(),
              )
            );
          }
        ),
        OperationButton(
          title: 'Back', 
          onTap: () => Navigator.of(context).pop(), 
          reversedColors: false
        ),
      ],
    );
  }
}

class ChooseUsersToGroupPage extends StatefulWidget {
  const ChooseUsersToGroupPage({super.key});

  static final String route = '/ChooseUsersToGroupPage';

  @override
  State<ChooseUsersToGroupPage> createState() => _ChooseUsersToGroupPageState();
}

class _ChooseUsersToGroupPageState extends State<ChooseUsersToGroupPage> {
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _settings.outerColor,
        padding: .only(top: MediaQuery.of(context).padding.top, bottom: 10),
        child: AccountsWidget()
      )
    );
  }
}