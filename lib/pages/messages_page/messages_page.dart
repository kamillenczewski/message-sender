import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/dialogs/accept_action_dialog.dart';
import 'package:messenger/dialogs/change_group_name_form.dart';
import 'package:messenger/dialogs/information_dialog.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/pages/widgets/account_image.dart';
import 'package:messenger/pages/add_users_to_group_page.dart';
import 'package:messenger/pages/widgets/custom_app_bar.dart';
import 'package:messenger/pages/widgets/group_image.dart';
import 'package:messenger/pages/login_or_register_page.dart';
import 'package:messenger/pages/messages_page/messages_widget.dart';
import 'package:messenger/pages/remove_users_from_group_page.dart';
import 'package:messenger/pages/show_users_in_group.dart';
import 'package:messenger/services/accounts_with_conversations_view_service.dart';
import 'package:messenger/services/edit_group_name_service.dart';
import 'package:messenger/services/group_account_links_table_service.dart';
import 'package:messenger/services/group_name_service.dart';
import 'package:messenger/widgets/operation_button.dart';
import 'package:messenger/widgets/send_message_field.dart';
import 'package:messenger/services/messages_table_service.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;


class CustomMenuButton extends StatefulWidget {
  final List<({String label, IconData? icon, void Function() callback})> _itemsData;
  final Widget? _innerWidget;

  const CustomMenuButton({
    super.key,
    this._innerWidget,
    required this._itemsData,
  });

  @override
  State<CustomMenuButton> createState() => _CustomMenuButtonState();
}

class _CustomMenuButtonState extends State<CustomMenuButton> {
  @override
  Widget build(BuildContext context) {
    final settings = Settings.instance;

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: settings.middleColor,
      ),
      child: PopupMenuButton(
        position: .under,
        padding: .all(12),
        color: settings.outerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: settings.innerColor, width: 1.5),
        ),
        icon: widget._innerWidget == null ? Icon(Icons.settings, color: settings.innerColor) : null,
        child: widget._innerWidget,
        itemBuilder: (context) {
          return widget._itemsData.map((data) =>
            PopupMenuItem(
              height: 0,
              padding: .only(top: 4, bottom: 4, left: 8, right: 4),
              child: Row(
                spacing: 5,
                children: [
                  data.icon == null
                  ? SizedBox()
                  : Icon(data.icon, color: settings.innerColor, size: 20),
                  Text(
                    data.label, 
                    style: TextStyle(
                      fontFamily: settings.fontFamily, 
                      color: settings.innerColor,
                      fontSize: 15
                    )
                  ),
                ],
              ),
              onTap: () => data.callback(),
            )
          ).toList();
        },
      ),
    );
  }
}

class AppBarLeftRow extends HookWidget {
  final Group _group;
  
  final _supabase = Supabase.instance.client;
  final _groupNameService = getIt<GroupNameService>();
  final _accountController = getIt<AccountController>();
  final _settings = Settings.instance;
  final _accountsWithConversationsViewService = getIt<AccountsWithConversationsViewService>();

  final kAvatarRadius = 24.0; 

  AppBarLeftRow({
    super.key,
    required this._group
  });

  @override
  Widget build(BuildContext context) {
    final groupName = useState<String>('');
    final accounts = useState<List<Account>>([]);

    void fetchData() async {
      groupName.value = await _groupNameService.get(_group.id);
      accounts.value = await _accountsWithConversationsViewService.getForGroup(_group.id);
    }
    
    useEffect(() {
      fetchData();

      final channel = _supabase
        .channel('public:${Group.kTable}:appBarLeftRow')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: Group.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();
      return () => _supabase.removeChannel(channel);
    }, [_group]);


    Widget createImageWidget() {
      if (accounts.value.isEmpty) {
        return SizedBox(width: kAvatarRadius * 2, height: kAvatarRadius * 2);
      }

      return _group.typeId == 0
      ?
      GroupImage(
        accounts: accounts.value, 
        groupName: groupName.value, 
        size: kAvatarRadius * 2
      )
      :
      AccountImage(
        accountId: accounts.value.where((e) => e.id != _accountController.account!.id).first.id, 
        accountName: groupName.value, 
        radius: kAvatarRadius
      );
    }

    return Expanded(
      child: Row(
        spacing: 16,
        children: [
          GestureDetector(
            child: Icon(Icons.arrow_back, color: _settings.innerColor, size: 30),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Theme(
            data: ThemeData(
              primaryColor: Colors.black
            ),
            child: createImageWidget()
          ),
          Expanded(
            child: Text(
              groupName.value,
              maxLines: 1,
              style: TextStyle(
                overflow: .ellipsis,
                fontFamily: _settings.fontFamily,
                color: _settings.innerColor,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
  
}

class MessagesPage extends StatefulWidget {
  final Group _group;

  const MessagesPage({
    super.key, 
    required this._group
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _messagesTableService = getIt<MessagesTableService>();
  final _accountController = getIt<AccountController>();
  final _groupAccountLinksTableService = getIt<GroupAccountLinksTableService>();
  final _editGroupNameService = getIt<EditGroupNameService>();
  final _scrollController = ScrollController();
  final _settings = Settings.instance;

  PreferredSize createGroupAppBar() {
    return createCustomAppBar(context,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          AppBarLeftRow(group: widget._group),
          CustomMenuButton(
            itemsData: [
              (
                callback: () {
                  showChangeGroupNameForm(context,
                    defaultText: widget._group.name,
                    onSubmitted: (value) async {
                      if (value.isEmpty) value = 'Your group';
          
                      if (value.length > 20) {
                        showInformationDialog(context, 'Max length of name is 20 characters!');
                        return;
                      }
          
                      await _editGroupNameService.edit(widget._group.id, value);
                    }
                  );
                }, 
                icon: Icons.edit, 
                label: 'Edit name '
              ),
              (
                callback: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => ShowUsersInGroupPage(group: widget._group),
                    )
                  );
                }, 
                icon: Icons.people, 
                label: 'Show members'
              ),
              (
                callback: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => AddUsersToGroupPage(group: widget._group),
                    )
                  );
                }, 
                icon: Icons.person_add, 
                label: 'Add member'
              ),
              (
                callback: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => RemoveUsersFromGroupPage(group: widget._group),
                    )
                  );
                }, 
                icon: Icons.person_remove, 
                label: 'Remove member'
              ),
              (
                callback: () {
                  showAcceptActionDialog(context, 
                    onAccept: () async {
                      await _groupAccountLinksTableService.delete(_accountController.account!.id, widget._group.id);
                    },
                    text: 'Are you sure you want to left this group?',
                    direction: .horizontal,
                    buttonWidth: 100
                  );
                }, 
                icon: Icons.logout, 
                label: 'Left group'
              )
            ]
          )   
        ],
      )
    );
  }

  PreferredSize createConversationAppBar() {
    return createCustomAppBar(context,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          AppBarLeftRow(group: widget._group),
        ],
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget._group.typeId == 1
      ? createConversationAppBar()
      : createGroupAppBar(),
      body: Container(
        padding: .only(left: 20, right: 20, bottom: 20),
        color: _settings.outerColor,
        child: ListenableBuilder(
          listenable: _accountController,
          builder: (context, child) {
            return _accountController.account == null
            ? 
            Center(
              child: OperationButton(
                title: 'Log In or Register', 
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => LoginOrRegisterPage(),
                  )
                )
              )
            )
            :
            Column(
              spacing: 12,
              children: [
                MessagesWidget(scrollController: _scrollController, group: widget._group),
                SendMessageField(
                  onSubmitted: (value) async {
                    await _messagesTableService.add(_accountController.account!.id, widget._group.id, value);
                  },
                ),
              ],
            );
          }
        ),
      )
    );
  }
}