import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/pages/groups_page/main_page.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/services/accounts_not_in_conversation_service.dart';
import 'package:messenger/services/get_conversation_service.dart';
import 'package:messenger/widgets/operation_button.dart';

final getIt = GetIt.instance;

class UserRow extends HookWidget {
  final String _userName;
  final void Function() _onTap;

  final _settings = Settings.instance;

  UserRow({
    super.key,
    required this._userName,
    required this._onTap
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    return HighlightedWidget(
      borderRadius: 8,
      onTap: () {
        if (!isLoading.value) {
          _onTap();
          isLoading.value = true;
        }
      },
      child: Text(
        _userName, 
        style: TextStyle(
          color: _settings.innerColor, 
          fontFamily: _settings.fontFamily,
          fontSize: 20
        )
      ),
    );
  }
}

class ChooseUserToConversation extends HookWidget {
  ChooseUserToConversation({super.key});
  
  final _accountsNotInConversationService = getIt<AccountsNotInConversationService>();
  final _getConversationService = getIt<GetConversationService>();
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final users = useState<List<Account>>([]);

    void fetchData() async {
      users.value = await _accountsNotInConversationService.get();
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
          users.value.isEmpty
          ?
          Center(
            child: Text(
              'You have conversations with all users!',
              textAlign: .center,
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
                itemCount: users.value.length,
                itemBuilder: (context, index) {
                  return UserRow(
                    userName: users.value[index].name, 
                    onTap: () async {
                      await _getConversationService.get(users.value[index].id);
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => MainPage(),
                        )
                      );
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

class ChooseUserToConversationPage extends StatefulWidget {
  const ChooseUserToConversationPage({super.key});

  @override
  State<ChooseUserToConversationPage> createState() => _ChooseUserToConversationPageState();
}

class _ChooseUserToConversationPageState extends State<ChooseUserToConversationPage> {
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _settings.outerColor,
        padding: .only(top: MediaQuery.of(context).padding.top, bottom: 10),
        child: ChooseUserToConversation()
      )
    );
  }
}