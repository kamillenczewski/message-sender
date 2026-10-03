import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/services/accounts_in_group_service.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class AccountsWidget extends HookWidget {
  final Group _group;

  AccountsWidget({super.key, required this._group});

  final _accountsInGroupService = getIt<AccountsInGroupService>();
  final _settings = Settings.instance;

  Widget createUserRow({
    required String userName, 
    required bool isChecked, 
    required void Function(bool) onChangeed
  }) {
    return HighlightedWidget(
      borderRadius: 8,
      onTap: () => onChangeed(!isChecked),
      child: Text(
        userName, 
        style: TextStyle(
          color: _settings.innerColor, 
          fontFamily: _settings.fontFamily,
          fontSize: 20
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final users = useState<List<Account>>([]);
    final isUserCheckedTable = useState<List<bool>>([]);

    void fetchData() async {
      users.value = await _accountsInGroupService.get(_group.id);
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
          title: 'Back', 
          onTap: () => Navigator.of(context).pop(), 
          reversedColors: false
        ),
      ],
    );
  }
}

class ShowUsersInGroupPage extends StatefulWidget {
  final Group _group;

  const ShowUsersInGroupPage({
    super.key, 
    required this._group,
  });

  @override
  State<ShowUsersInGroupPage> createState() => _ShowUsersInGroupPageState();
}

class _ShowUsersInGroupPageState extends State<ShowUsersInGroupPage> {
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