import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/db_models/group_account_link.dart';
import 'package:messenger/db_models/group_message.dart';
import 'package:messenger/pages/groups_page/group_box.dart';
import 'package:messenger/pages/groups_page/group_section.dart';
import 'package:messenger/services/accounts_with_conversations_view_service.dart';
import 'package:messenger/services/groups_latest_messages_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class GroupsWidget extends HookWidget {
  final GroupSection _section;

  final _supabase = Supabase.instance.client;
  final _groupsLatestMessagesService = getIt<GroupsLatestMessagesService>();
  final _accountsWithConversationsViewService = getIt<AccountsWithConversationsViewService>();

  GroupsWidget({
    super.key,
    required this._section
  });

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final isLoading = useState(true);
    final latestMessagesView = useState<List<({String accountName, String content, int datetime, Group group})>>([]);
    final conversationToAccountsMap = useState<Map<int, List<Account>>>({});

    void fetchData() async {
      isLoading.value = true;

      if (_section == .all) {
        latestMessagesView.value = await _groupsLatestMessagesService.get();
      } 
      else if (_section == .conversations) {
        latestMessagesView.value = await _groupsLatestMessagesService.getConversations();
      } 
      else {
        latestMessagesView.value = await _groupsLatestMessagesService.getNotConversations();
      }

      conversationToAccountsMap.value = await _accountsWithConversationsViewService.getForAllGroups_NEW();
      isLoading.value = false;
    }

    useEffect(() {
      fetchData();

      final groupsChannel = _supabase
        .channel('public:${Group.kTable}:groups_widget')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: Group.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();

      final messagesChannel = _supabase
        .channel('public:${GroupMessage.kTable}:groups_widget')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: GroupMessage.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();

      final groupLinksChannel = _supabase
        .channel('public:${GroupAccountLink.kTable}:1')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: GroupAccountLink.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();

      return () {
        _supabase.removeChannel(groupsChannel);
        _supabase.removeChannel(messagesChannel);
        _supabase.removeChannel(groupLinksChannel);
      };
    }, [_section]);

    if (isLoading.value) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
          child: CircularProgressIndicator()
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: latestMessagesView.value.length,
        itemBuilder: (context, index) {
          final record = latestMessagesView.value[index];

          return Column(
            children: [
              GroupBox(
                group: record.group, 
                accountName: record.accountName, 
                content: record.content, 
                datetime: record.datetime,
                accounts: conversationToAccountsMap.value[record.group.id],
              ),
              SizedBox(height: 8)
            ],
          );
        }
      ),
    );
  }
}