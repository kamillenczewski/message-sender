import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/services/accounts_not_in_group_service.dart';
import 'package:messenger/services/add_accounts_to_group_servicre.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class AccountsWidget extends HookWidget {
  final Group _group;

  AccountsWidget({super.key, required this._group});

  final _addAccountsToGroupServicre = getIt<AddAccountsToGroupServicre>();
  final _accountsNotInGroupService = getIt<AccountsNotInGroupService>();
  final _settings = Settings.instance;

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
      users.value = await _accountsNotInGroupService.get(_group.id);
      isUserCheckedTable.value = users.value.map((e) => false).toList();
    }

    useEffect(() {
      fetchData();
      return null;
    }, []);

    return Column(
      spacing: 8,
      children: [
        Expanded(
          child: 
          isUserCheckedTable.value.isEmpty
          ?
          Center(
            child: Text(
              'All users are in the group!',
              style: TextStyle(
                color: _settings.innerColor,
                fontFamily: _settings.fontFamily,
                fontSize: 30
              ),
            ),
          )
          :
          StatefulBuilder(
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
        isUserCheckedTable.value.isEmpty
        ?
        SizedBox.shrink()
        :
        OperationButton(
          title: 'Submit', 
          onTap: () async {
            final usersToGroup = List
              .generate(users.value.length, (index) => index)
              .where((index) => isUserCheckedTable.value[index])
              .map((index) => users.value[index])
              .map((e) => e.id)
              .toList();

            if (usersToGroup.isEmpty) return;

            await _addAccountsToGroupServicre.add(_group.id, usersToGroup);
            Navigator.of(context).pop();
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

class AddUsersToGroupPage extends StatefulWidget {
  final Group _group;

  const AddUsersToGroupPage({
    super.key, 
    required this._group,
  });

  @override
  State<AddUsersToGroupPage> createState() => _AddUsersToGroupPageState();
}

class _AddUsersToGroupPageState extends State<AddUsersToGroupPage> {
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _settings.outerColor,
        padding: .only(top: MediaQuery.of(context).padding.top, bottom: 10),
        child: AccountsWidget(group: widget._group)
      )
    );
  }
}