import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/dialogs/accept_action_dialog.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/db_models/group_account_link.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/services/accounts_in_group_service.dart';
import 'package:messenger/services/remove_users_from_group_service.dart';
import 'package:messenger/widgets/operation_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class AccountsWidget extends HookWidget {
  final Group _group;

  AccountsWidget({super.key, required this._group});

  final _accountsInGroupService = getIt<AccountsInGroupService>();
  final _removeUsersFromGroupService = getIt<RemoveUsersFromGroupService>();
  final _settings = Settings.instance;
  final _supabase = Supabase.instance.client;


  void _onDelete(BuildContext context, Account user) {
    showAcceptActionDialog(context,
      onAccept: () async {
        await _removeUsersFromGroupService.remove(_group.id, user.id);
      },
      text: "Are you sure you want to remove user '${user.name}' from group '${_group.name}'?",
      direction: .horizontal,
      buttonWidth: 100
    );
  }

  Widget createUserRow(BuildContext context, {
    required Account user
  }) {
    return HighlightedWidget(
      borderRadius: 8,
      onTap: () => _onDelete(context, user),
      child: Container(
        padding: .all(4),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              user.name, 
              style: TextStyle(
                color: _settings.innerColor, 
                fontFamily: _settings.fontFamily,
                fontSize: 20
              )
            ),
            GestureDetector(
              child: Icon(
                Icons.delete, 
                color: _settings.innerColor,
                size: 30
              ),
              onTap: () => _onDelete(context, user),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final users = useState<List<Account>>([]);

    void fetchData() async {
      users.value = await _accountsInGroupService.get(_group.id);
    }

    useEffect(() {
      fetchData();
  
      final channel = _supabase
        .channel('public:${GroupAccountLink.kTable}:${runtimeType.toString()}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: GroupAccountLink.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();

      return () => _supabase.removeChannel(channel);
    }, []);

    return Column(
      spacing: 8,
      children: [
        Expanded(
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView.builder(
                itemCount: users.value.length,
                itemBuilder: (context, index) {
                  return createUserRow(context,
                    user: users.value[index], 
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

class RemoveUsersFromGroupPage extends StatefulWidget {
  final Group _group;

  const RemoveUsersFromGroupPage({
    super.key, 
    required this._group,
  });

  @override
  State<RemoveUsersFromGroupPage> createState() => _RemoveUsersFromGroupPageState();
}

class _RemoveUsersFromGroupPageState extends State<RemoveUsersFromGroupPage> {
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